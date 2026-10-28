"""Collect measurements for the human audit report after run_tests.py succeeds."""
import json
import platform
from pathlib import Path
import pymupdf as fitz

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'build'/'audit'


def spans(page):
    return [s for b in page.get_text('dict')['blocks'] if 'lines' in b
            for line in b['lines'] for s in line['spans']]


def summarize(path):
    doc = fitz.open(path)
    return {
        'pages': len(doc), 'paper-pt': list(doc[0].rect),
        'fonts': sorted({f[3].split('+')[-1] for p in doc for f in p.get_fonts()}),
        'body-headers': [s for p in doc for s in spans(p) if s['text'] == '西南交通大学硕士学位论文'][:2],
        'footers': [s for p in doc for s in spans(p) if s['text'].strip().isdigit() and s['origin'][1] > 755][:2],
        'cover-stroke-text-traces': sum(t['type'] == 1 for t in doc[0].get_texttrace()),
    }


def main():
    evidence = {
        'python': platform.python_version(),
        'tests': json.loads((OUT/'test-results.json').read_text(encoding='utf-8')),
        'official-docx-sha256': json.loads((OUT/'official-ooxml.json').read_text(encoding='utf-8'))['sha256'],
        'master-example': summarize(OUT/'master-example.pdf'),
        'master-regression': summarize(OUT/'master-academic.pdf'),
    }
    official = fitz.open(OUT/'official.pdf')
    evidence['official-footer'] = [s for s in spans(official[11]) if s['text'].strip() == '1'][0]
    regression = fitz.open(OUT/'master-academic.pdf')
    bib = next(p for p in regression if '[10]' in p.get_text())
    number = next(s for s in spans(bib) if s['text'] == '[1]')
    first = next(s for s in spans(bib) if s['text'] == '蒋有绪')
    evidence['bibliography-indent-pt'] = first['origin'][0]-number['origin'][0]
    evidence['bibliography-baselines'] = sorted({round(s['origin'][1],3) for s in spans(bib)
                                               if 135 < s['origin'][1] < 740})
    evidence['table-pages'] = [i+1 for i,p in enumerate(regression) if '参数或工况' in p.get_text()]
    for name in ['master-example','master-academic']:
        doc = fitz.open(OUT/(name+'.pdf'))
        evidence[name+'-header-lines'] = [
            {'page': i+1, 'rect': list(d['rect']), 'width': d['width']}
            for i,p in enumerate(doc) for d in p.get_drawings()
            if 70 < d['rect'].y0 < 85 and d['rect'].width > 400
        ][:2]
    (OUT/'evidence.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Evidence saved to', OUT/'evidence.json')


if __name__ == '__main__':
    main()
