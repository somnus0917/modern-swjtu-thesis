"""Compile local sources and verify PDF behavior; never modifies Git or package caches.

Requires Typst 0.15.1, PyMuPDF and Pillow. Run from any working directory.
Visual review remains a separate mandatory gate; assertions are not a visual verdict.
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
import pymupdf as fitz
from audit_pdf import inspect
from check_cover import check_official_cover, check_fill_centers

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'build'/'audit'
CASES = {
    'master-academic': {},
    'master-professional': {'degree': 'professional'},
    'master-duplex': {'twoside': 'true'},
    'professional-duplex': {'degree': 'professional', 'twoside': 'true'},
    'optional-off': {'optional': 'none'},
    'optional-tables': {'optional': 'tables'},
    'empty-lists': {'empty': 'true'},
    'long-fields': {'long': 'true'},
    'many-figures': {'many': '60'},
    'anonymous': {'anonymous': 'true'},
}


def compile_pdf(name, source, inputs=None, expected_error=None):
    command = ['typst', 'compile', '--root', str(ROOT)]
    for key, value in (inputs or {}).items():
        command += ['--input', f'{key}={value}']
    pdf = OUT/(name+'.pdf')
    result = subprocess.run(command+[str(source), str(pdf)], cwd=ROOT,
                            capture_output=True, encoding='utf-8')
    (OUT/(name+'.log')).write_text(result.stdout+result.stderr, encoding='utf-8')
    if expected_error:
        assert result.returncode != 0 and expected_error in result.stderr, result.stderr
        return {'expected-error': expected_error}
    assert result.returncode == 0, result.stderr
    if name != 'bachelor-current':
        assert not result.stderr.strip(), result.stderr
    inspect(pdf, OUT/name)
    if name == 'bachelor-current':
        doc = fitz.open(pdf)
        return {'pages': len(doc), 'preexisting-missing-glyph-pages':
                [i+1 for i,p in enumerate(doc) if '\ufffd' in p.get_text() or '\x00' in p.get_text()],
                'criterion': 'Pixel-identical to both bachelor baselines; not master conformance'}
    return check_pdf(pdf, inputs or {})


def normalize(text):
    return re.sub(r'[\s\u2060]+', '', text)


def all_spans(page):
    return [s for b in page.get_text('dict')['blocks'] if 'lines' in b
            for line in b['lines'] for s in line['spans']]


def check_pdf(path, inputs):
    doc = fitz.open(path)
    result = {'pages': len(doc), 'blank-pages': [], 'pdf-sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    for i, page in enumerate(doc):
        text = page.get_text()
        assert '\ufffd' not in text and '\x00' not in text, (path.name, i+1, 'missing glyph')
        if not text.strip() and not page.get_images():
            assert not page.get_drawings(), (path.name, i+1, 'blank page has graphics')
            result['blank-pages'].append(i+1)
        for span in all_spans(page):
            if not span['text'].strip():
                continue
            x0, y0, x1, y1 = span['bbox']
            assert x0 >= -1 and x1 <= page.rect.width+1 and y0 >= -1 and y1 <= page.rect.height+1, (path.name, i+1, span)
    return result


def check_master(name, inputs):
    doc = fitz.open(OUT/(name+'.pdf'))
    texts = [normalize(page.get_text()) for page in doc]
    entire = ''.join(texts)
    for page in doc:
        for span in all_spans(page):
            if span['text'] in ('图目录','表目录') and span['origin'][1] > 100:
                middle = (span['bbox'][0]+span['bbox'][2])/2
                assert abs(middle-page.rect.width/2) < .02, (name,span)
    if inputs.get('anonymous') == 'true':
        assert '测试作者' not in entire and 'TestAuthor' not in entire and '2026000001' not in entire
        assert not doc.metadata.get('author')
    duplex = inputs.get('twoside') == 'true'
    if duplex:
        for title in ['学位论文独创性声明', '学位论文使用授权', '摘\u3000要', 'ABSTRACT']:
            found = [i for i,p in enumerate(doc) if normalize(title) in normalize(p.get_text())]
            assert found and all(i%2 == 0 for i in found), (name, title, found)
    if inputs.get('empty') != 'true':
        for phrase in ['图1-1', '图2-1', '表1-2', '表A-1', '表B-1', '(1-1)', '(2-1)', '(A-1)', '(B-1)']:
            assert phrase in entire, (name, phrase)
        long_pages = [i for i, page in enumerate(doc) if '参数或工况' in page.get_text()]
        assert len(long_pages) >= 2
        assert '续表1-2' not in texts[long_pages[0]], (name, 'first table page says continued')
        for i in long_pages[1:]:
            assert '续表1-2' in texts[i], (name, i, 'missing continued title')
        for row in range(80):
            assert sum(f'工况{row}：' in t for t in texts) == 1, (name, row)
    else:
        assert not any(p.get_text().startswith(('图目录\n', '表目录\n')) for p in doc), name
    if inputs.get('optional') == 'none':
        assert not any(p.get_text().startswith(('图目录\n', '表目录\n')) for p in doc)
    if inputs.get('optional') == 'tables':
        assert not any(p.get_text().startswith('图目录\n') for p in doc)
        assert any(p.get_text().startswith('表目录\n') for p in doc)
    body_start = next(i for i,t in enumerate(texts) if '正文首段' in t)
    for i in range(body_start, len(doc)):
        page, text = doc[i], doc[i].get_text()
        if not text.strip():
            continue
        spans = all_spans(page)
        for span in spans:
            if span['text'] == '西南交通大学硕士学位论文':
                assert abs(span['size']-10.5) < .01 and 'SimSun' in span['font']
            if span['origin'][1] > 755 and span['text'].strip().isdigit():
                assert abs(span['size']-9) < .01 and 'TimesNewRoman' in span['font']
            if span['origin'][1] > 80 and span['origin'][1] < 751 and span['text'].strip():
                # PDF 字形 bbox 包括中文行尾标点被压缩的半字空白，不能当成墨迹越界。
                right = span['bbox'][2] - (span['size']/2 if span['text'][-1] in '。，；：！？）》】' else 0)
                assert span['bbox'][0] >= 82 and right <= 515, (name,i+1,span)
        # 独立检查右页边距中的实际墨迹，避免 bbox 修正掩盖溢出。
        clip = fitz.Rect(512, 85, page.rect.width, 750)
        pix = page.get_pixmap(matrix=fitz.Matrix(2,2), clip=clip, colorspace=fitz.csGRAY)
        assert min(pix.samples, default=255) > 100, (name,i+1,'ink in right margin')
        assert '□' not in text, (name, i+1, 'tofu in body')
        if duplex and re.search('第[12]章|致谢|参考文献|附录A|攻读硕士学位', normalize(text[13:60])):
            assert i%2 == 0, (name, i+1, 'chapter begins on verso')
    # 验证实际嵌入的西文粗体和数学字体，不能以源码参数替代。
    fonts = {f[3] for page in doc for f in page.get_fonts()}
    assert any('TimesNewRomanPS-Bold' in f for f in fonts), fonts
    assert any('CambriaMath' in f for f in fonts), fonts
    assert not any('NewCM' in f for f in fonts), fonts
    # 五号参考文献，固定 20pt 基线与 26.25pt 悬挂缩进。
    bib = next(page for page in doc if '[10]' in page.get_text())
    spans = all_spans(bib)
    number = next(s for s in spans if s['text'] == '[1]')
    first = next(s for s in spans if s['text'] == '蒋有绪')
    assert abs(first['origin'][0]-number['origin'][0]-26.25) < .02
    baselines = sorted({round(s['origin'][1], 2) for s in spans if 135 < s['origin'][1] < 740})
    assert all(abs((b-a)/20-round((b-a)/20)) < .003 for a,b in zip(baselines,baselines[1:])), baselines


def regression_pixels(current, previous):
    a, b = fitz.open(current), fitz.open(previous)
    assert len(a) == len(b), (len(a), len(b))
    differences = [i+1 for i,(p,q) in enumerate(zip(a,b))
                   if p.get_pixmap().samples != q.get_pixmap().samples]
    return {'pages': len(a), 'different-pages': differences}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    results = {'typst': subprocess.check_output(['typst','--version'], encoding='utf-8').strip(), 'cases': {}}
    for name, inputs in CASES.items():
        print(name, flush=True)
        results['cases'][name] = compile_pdf(name, ROOT/'tests'/'master-regression.typ', inputs)
        check_master(name, inputs)
    results['cases']['cover-fields'] = compile_pdf('cover-fields', ROOT/'tests'/'cover-fields.typ')
    check_fill_centers(OUT/'cover-fields.pdf', cover_pages=4)
    results['cases']['cover-official'] = compile_pdf('cover-official', ROOT/'tests'/'cover-official.typ')
    check_official_cover(OUT)
    results['cases']['cover-overflow'] = compile_pdf('cover-overflow', ROOT/'tests'/'cover-fields.typ',
        {'overflow':'true'}, '中文封面填写栏总高度超过可用区域')
    results['cases']['master-example'] = compile_pdf('master-example', ROOT/'template'/'thesis-master.typ', {'local':'true'})
    check_fill_centers(OUT/'master-example.pdf')
    results['cases']['heading-spacing'] = compile_pdf('heading-spacing', ROOT/'tests'/'heading-spacing.typ')
    heading_page = fitz.open(OUT/'heading-spacing.pdf')[0]
    positions = {s['text']: s['origin'][1] for s in all_spans(heading_page)}
    for before, after, distance in [
        ('章标题','连续二级',38), ('正文甲。','非连续二级',38.4),
        ('正文乙。','非连续三级',32.4), ('连续组二级','连续组三级',26),
        ('连续组三级','连续组四级',26), ('正文丁。','独立段落甲。',20),
        ('独立段落甲。','独立段落乙。',20),
    ]:
        assert abs(positions[after]-positions[before]-distance) < .02, (before,after,positions)
    results['cases']['reference-format'] = compile_pdf('reference-format', ROOT/'tests'/'reference-format.typ')
    references_pdf = fitz.open(OUT/'reference-format.pdf')
    bib_text = normalize(references_pdf[1].get_text())
    for expected in ['LiMM,HarringtonRF,TestA,etal.', 'TheanalysisofbidirectionalDCconvertercontrol',
                     'IEEETransactionsonPowerElectronics', '作者甲,作者乙,作者丙,等.', 'TEST123-2026[S]']:
        assert expected in bib_text, expected
    markers = [s for s in all_spans(references_pdf[0]) if s['text'] == '[1]']
    assert len(markers) == 2 and markers[0]['size'] < 9 and abs(markers[1]['size']-12) < .01
    assert len(references_pdf[0].get_links()) >= 2
    # 多页参考文献：人为构造排版数据，验证每条文献不会被拆到两页。
    references = '\n'.join('@book{stress%03d, author={Test, Author}, title={START%03d %s END%03d}, year={2026}, publisher={Test Press}}'
        % (i,i,('Typesetting verification and bibliography pagination. '*5),i) for i in range(32))
    (OUT/'stress.bib').write_text(references, encoding='utf-8')
    (OUT/'bibliography-stress.typ').write_text('''#import "/lib.typ": documentclass
#let cls = documentclass(doctype: "master", bibliography: bibliography.with("stress.bib"))
#show: cls.doc
#show: cls.mainmatter
#(cls.bilingual-bibliography)(full: true)
''', encoding='utf-8')
    results['cases']['bibliography-stress'] = compile_pdf('bibliography-stress', OUT/'bibliography-stress.typ')
    bibliography = fitz.open(OUT/'bibliography-stress.pdf')
    for i in range(32):
        found = [p.get_text().lower() for p in bibliography if f'start{i:03d}' in p.get_text().lower() or f'end{i:03d}' in p.get_text().lower()]
        assert len(found) == 1 and f'start{i:03d}' in found[0] and f'end{i:03d}' in found[0], i
    # 扫描声明页不改变原图内容与长宽比，也不额外插入空页。
    from PIL import Image, ImageDraw
    for i in (1,2):
        scan = Image.new('RGB', (595,842), 'white')
        ImageDraw.Draw(scan).text((80,80), f'SCAN TEST {i}', fill='black')
        scan.save(OUT/f'scan-{i}.png')
    (OUT/'scans.typ').write_text('''#import "/lib.typ": documentclass
#let cls = documentclass(doctype: "master")
#show: cls.doc
#(cls.decl-page)(scans: (image("scan-1.png"), image("scan-2.png")))
''', encoding='utf-8')
    results['cases']['scans'] = compile_pdf('scans', OUT/'scans.typ')
    scans = fitz.open(OUT/'scans.pdf')
    assert len(scans) == 2 and all(len(page.get_images()) == 1 for page in scans)
    stage = OUT/'current-template'
    shutil.copytree(ROOT/'template', stage, dirs_exist_ok=True)
    bachelor = stage/'thesis.typ'
    bachelor.write_text(re.sub(r'"@preview/modern-swjtu-thesis:[^"]+"', '"/lib.typ"',
                              bachelor.read_text(encoding='utf-8')), encoding='utf-8')
    results['cases']['bachelor-current'] = compile_pdf('bachelor-current', bachelor)
    for baseline in ['before','original']:
        result = regression_pixels(OUT/'bachelor-current.pdf', OUT/(baseline+'-thesis.pdf'))
        results['bachelor-vs-'+baseline] = result
        assert not result['different-pages'], result
    (OUT/'test-results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
