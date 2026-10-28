"""Measure cover glyphs and ruling anchors, rather than compilation alone."""
import json
from pathlib import Path
import pymupdf as fitz
from PIL import Image, ImageDraw


def chars(page):
    return [c for b in page.get_text('rawdict')['blocks'] for line in b.get('lines', [])
            for span in line['spans'] for c in span['chars'] if not c['c'].isspace()]


def check_fill_centers(path, expected_rows=None, cover_pages=2):
    doc = fitz.open(path)
    count = 0
    for i, page in enumerate(list(doc)[:cover_pages]):
        # Empty and long-field fixture repeats Chinese / English cover pairs.
        rules = [d['rect'] for d in page.get_drawings()
                 if 465 < d['rect'].y0 < 735
                 and d['rect'].width > 150 and d['rect'].height < 1]
        glyphs = chars(page)
        for rule in rules:
            left = rule.x0
            label_width = 96.02 if i % 2 == 0 else 81.4
            assert abs((rule.x0-label_width+rule.x1)/2-page.rect.width/2) < .02
            assert rule.x0-label_width >= 85 and rule.x1 <= page.rect.width-85
            row = [c for c in glyphs if c['origin'][0] >= left-.01
                   and abs(c['origin'][1]-(rule.y0-2)) < .1]
            if not row:
                continue
            center = (min(c['bbox'][0] for c in row)+max(c['bbox'][2] for c in row))/2
            assert abs(center-(rule.x0+rule.x1)/2) < .1, (path, i+1, center, rule)
            count += 1
    assert count >= 5, (path,count)
    if expected_rows is not None:
        assert count == expected_rows, (path, count, expected_rows)
    return count


def check_official_cover(output):
    doc = fitz.open(output/'cover-official.pdf')
    # Frozen from the supplied official Word PDF, in physical page points.
    expected = [('学科专业',475.63), ('学号',506.83), ('作者姓名',538.03),
                ('指导老师',569.23), ('学院',600.46)]
    glyphs = chars(doc[0])
    for label, baseline in expected:
        row = [c for c in glyphs if abs(c['origin'][1]-baseline) < .1]
        assert ''.join(c['c'] for c in row) == label, row
        assert abs(row[0]['origin'][0]-175.73) < .05
        assert abs(row[-1]['origin'][0]-255.5) < .3, row
    for index, baseline in enumerate([477.67,508.87,540.07,571.27,602.5]):
        rules = [d['rect'] for d in doc[0].get_drawings()
                 if abs(d['rect'].y0-baseline) < .1 and abs(d['rect'].x0-271.75) < .1]
        assert len(rules) == 1 and abs(rules[0].x1-431.74) < .05, (index,rules)
    en = doc[1].get_text('dict')
    spans = [s for b in en['blocks'] for line in b.get('lines',[]) for s in line['spans']]
    for text, baseline in [('A Thesis Submitted to',116.06),
                           ('Southwest Jiaotong University for Master Degree',147.26),
                           ('Thesis Template for Master Degree of',251.54),
                           ('Engineering in',282.77), ('Southwest Jiaotong University',313.97),
                           ('Jan. 8, 2024',740.86)]:
        span = next(s for s in spans if s['text'].strip() == text)
        assert abs(span['origin'][1]-baseline) < .05, (text,span)
    # Measure every corresponding label glyph against the live official PDF too.
    evidence = {'chinese-label-baselines-pt': [b for _,b in expected],
                'chinese-rule-start-pt':271.75, 'chinese-rule-end-pt':431.74}
    official_path = output/'official.pdf'
    if official_path.exists():
        official = fitz.open(official_path)
        a = [c for c in chars(official[0]) if 465<c['origin'][1]<610]
        b = [c for c in glyphs if 465<c['origin'][1]<610]
        assert ''.join(c['c'] for c in a) == ''.join(c['c'] for c in b)
        error = max(abs(u-v) for c,d in zip(a,b) for u,v in zip(c['origin'],d['origin']))
        assert error < .4, error
        evidence['max-label-origin-error-pt'] = error
        for i in range(2):
            pages = []
            for source in (official,doc):
                pix = source[i].get_pixmap(matrix=fitz.Matrix(1.5,1.5),alpha=False)
                pages.append(Image.frombytes('RGB',(pix.width,pix.height),pix.samples))
            sheet = Image.new('RGB',(pages[0].width*2,pages[0].height+30),'white')
            for j,page in enumerate(pages):
                sheet.paste(page,(j*page.width,30))
                ImageDraw.Draw(sheet).text((j*page.width+20,8),
                                          'Official Word' if j==0 else 'Current Typst',fill='black')
            sheet.save(output/f'cover-comparison-{i+1}.png')
    (output/'cover-evidence.json').write_text(json.dumps(evidence,indent=2),encoding='utf-8')
    return evidence
