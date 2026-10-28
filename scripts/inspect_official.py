"""Extract inherited OOXML properties without changing the official DOCX.

Usage: python scripts/inspect_official.py reference.docx build/audit
The JSON includes the source of each effective attribute, not just direct style.
"""
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile
from lxml import etree as E

NS = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
W = '{' + NS['w'] + '}'
TOGGLES = {'b', 'bCs', 'i', 'iCs', 'caps', 'smallCaps', 'strike', 'outline', 'shadow', 'emboss', 'imprint'}


def props(node, source, prefix=''):
    result = {}
    if node is not None:
        for child in node:
            tag = E.QName(child).localname
            key_prefix = prefix + tag
            attrs = {E.QName(k).localname: v for k, v in child.attrib.items()}
            if tag in TOGGLES:
                attrs['val'] = attrs.get('val', '1') not in ('0', 'false', 'off')
            if attrs:
                for key, value in attrs.items():
                    result[f'{key_prefix}.{key}'] = {'value': value, 'source': source}
            elif len(child) == 0:
                result[key_prefix] = {'value': True, 'source': source}
            result.update(props(child, source, key_prefix+'.'))
    return result


def merge_style(base, addition):
    """OOXML style toggles invert inherited state; direct formatting does not."""
    result = merge_props(base, addition)
    for key, value in addition.items():
        if key.removesuffix('.val') in TOGGLES and key.endswith('.val'):
            if value['value']:
                value = dict(value, value=not base.get(key, {}).get('value', False))
            elif key in base:
                value = base[key]  # false in a style leaves the inherited toggle unchanged
        result[key] = value
    return result


def merge_props(base, addition):
    result = dict(base)
    # 更具体层级设置字体时，覆盖前级同一文字范围的主题/显式字体选择。
    for slot, theme in [('ascii', 'asciiTheme'), ('hAnsi', 'hAnsiTheme'),
                        ('eastAsia', 'eastAsiaTheme'), ('cs', 'cstheme')]:
        direct_key, theme_key = 'rFonts.'+slot, 'rFonts.'+theme
        if direct_key in addition and theme_key not in addition:
            result.pop(theme_key, None)
        elif theme_key in addition and direct_key not in addition:
            result.pop(direct_key, None)
    result.update(addition)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('docx', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    with ZipFile(args.docx) as archive:
        styles = E.fromstring(archive.read('word/styles.xml'))
        document = E.fromstring(archive.read('word/document.xml'))
        theme = E.fromstring(archive.read('word/theme/theme1.xml'))
        lookup = {s.get(W+'styleId'): s for s in styles.findall('w:style', NS)}
        default_style = next((k for k, s in lookup.items()
                              if s.get(W+'type') == 'paragraph' and s.get(W+'default') == '1'), None)

        def inherited(style_id, kind, seen=()):
            if style_id not in lookup or style_id in seen:
                return {}
            style = lookup[style_id]
            base = style.find('w:basedOn', NS)
            values = inherited(base.get(W+'val'), kind, seen+(style_id,)) if base is not None else {}
            return merge_style(values, props(style.find('w:'+kind, NS), 'style:'+style_id))

        defaults = styles.find('w:docDefaults', NS)
        pdefault = props(defaults.find('w:pPrDefault/w:pPr', NS), 'docDefaults')
        rdefault = props(defaults.find('w:rPrDefault/w:rPr', NS), 'docDefaults')
        paragraphs = []
        for i, paragraph in enumerate(document.findall('.//w:body//w:p', NS)):
            ppr = paragraph.find('w:pPr', NS)
            ps = paragraph.find('w:pPr/w:pStyle', NS)
            sid = ps.get(W+'val') if ps is not None else default_style
            pp = merge_props(merge_props(pdefault, inherited(sid, 'pPr')), props(ppr, f'paragraph:{i}'))
            runs = []
            for j, run in enumerate(paragraph.findall('.//w:r', NS)):
                rs = run.find('w:rPr/w:rStyle', NS)
                rp = merge_props(rdefault, inherited(sid, 'rPr'))
                if rs is not None:
                    rp = merge_props(rp, inherited(rs.get(W+'val'), 'rPr'))
                rp = merge_props(rp, props(run.find('w:rPr', NS), f'paragraph:{i}/run:{j}'))
                text = ''.join(run.xpath('.//w:t/text()', namespaces=NS))
                ans = {'a': 'http://schemas.openxmlformats.org/drawingml/2006/main'}
                effective_fonts = {}
                for slot in ('ascii', 'hAnsi', 'eastAsia', 'cs'):
                    explicit = rp.get('rFonts.'+slot)
                    if explicit is not None:
                        effective_fonts[slot] = explicit
                        continue
                    themed = rp.get('rFonts.'+slot+'Theme', rp.get('rFonts.cstheme') if slot == 'cs' else None)
                    if themed:
                        family = 'majorFont' if themed['value'].startswith('major') else 'minorFont'
                        part = 'ea' if slot == 'eastAsia' else ('cs' if slot == 'cs' else 'latin')
                        font = theme.find(f'.//a:{family}/a:{part}', ans)
                        name = font.get('typeface', '') if font is not None else ''
                        if not name and slot == 'eastAsia':
                            font = theme.find(f'.//a:{family}/a:font[@script="Hans"]', ans)
                            name = font.get('typeface', '') if font is not None else ''
                        effective_fonts[slot] = {'value': name, 'source': 'theme:'+themed['value']}
                runs.append({'text': text, 'properties': rp, 'effective-fonts': effective_fonts})
            paragraphs.append({'index': i, 'style': sid, 'text': ''.join(r['text'] for r in runs),
                               'paragraph': pp, 'runs': runs})
        sections = [E.tostring(s, encoding='unicode') for s in document.findall('.//w:sectPr', NS)]
        tables = [E.tostring(s, encoding='unicode') for s in document.findall('.//w:tbl', NS)]
        headers = {n: archive.read(n).decode('utf-8') for n in archive.namelist()
                   if n.startswith(('word/header', 'word/footer')) and n.endswith('.xml')}
        result = {'source': str(args.docx.resolve()), 'sha256': hashlib.sha256(args.docx.read_bytes()).hexdigest(),
                  'paragraphs': paragraphs, 'sections': sections, 'tables': tables, 'headers': headers,
                  'theme': E.tostring(theme, encoding='unicode'),
                  'styles': E.tostring(styles, encoding='unicode'),
                  'numbering': archive.read('word/numbering.xml').decode('utf-8')}
        (args.output/'official-ooxml.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
        (args.output/'official-paragraphs.txt').write_text('\n'.join(f"P{p['index']} [{p['style']}] {p['text']}" for p in paragraphs), encoding='utf-8')
    print(f'Extracted {len(paragraphs)} paragraphs, {len(sections)} sections, {len(tables)} tables')


if __name__ == '__main__':
    main()
