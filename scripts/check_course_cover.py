"""Course cover regression: native ruling, automatic width and centering."""
import subprocess
from pathlib import Path
import pymupdf as fitz

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'build'/'audit'


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    widths = {}
    for mode in ('normal', 'empty', 'long', 'overflow'):
        path = OUT/f'course-cover-{mode}.pdf'
        result = subprocess.run(['typst','compile','--root',str(ROOT),'--input',f'mode={mode}',
                                 str(ROOT/'tests'/'course-cover.typ'),str(path)],
                                capture_output=True, encoding='utf-8')
        if mode == 'overflow':
            assert result.returncode and '课程封面填写栏总高度超过可用区域' in result.stderr
            continue
        assert result.returncode == 0 and not result.stderr, result.stderr
        doc = fitz.open(path)
        assert len(doc) == 1
        page = doc[0]
        rules = [d['rect'] for d in page.get_drawings()
                 if 425 < d['rect'].y0 < 610 and d['rect'].width > 150 and d['rect'].height < 1]
        assert len(rules) == (6 if mode == 'long' else 5), (mode,rules)
        assert max(r.width for r in rules)-min(r.width for r in rules) < .01
        widths[mode] = rules[0].width
        chars = [c for b in page.get_text('rawdict')['blocks'] for l in b.get('lines',[])
                 for s in l['spans'] for c in s['chars'] if not c['c'].isspace()]
        for rule in rules:
            assert abs((rule.x0-96.02+rule.x1)/2-page.rect.width/2) < .02
            assert rule.x0-96.02 >= 85 and rule.x1 <= page.rect.width-85
            row = [c for c in chars if c['origin'][0] >= rule.x0-.01
                   and abs(c['origin'][1]-(rule.y0-2)) < .1]
            if mode != 'empty':
                assert row
                assert abs((min(c['bbox'][0] for c in row)+max(c['bbox'][2] for c in row))/2
                           -(rule.x0+rule.x1)/2) < .1
        label_rows = [[c for c in chars if abs(c['origin'][1]-(r.y0-2)) < .1
                       and c['origin'][0] < r.x0-.1] for r in rules]
        starts = [row[0]['origin'][0] for row in label_rows if row]
        assert max(starts)-min(starts) < .01
        page.get_pixmap(matrix=fitz.Matrix(1.5,1.5),alpha=False).save(OUT/f'course-cover-{mode}.png')
    assert widths['long'] > widths['normal'] >= widths['empty']
    print('Course cover: normal / empty / long / expected overflow passed.')


if __name__ == '__main__':
    main()
