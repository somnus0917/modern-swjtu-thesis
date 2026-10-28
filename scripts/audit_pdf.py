"""Render every PDF page and save text/font/geometry evidence and contact sheets."""
import argparse
import json
from pathlib import Path
import pymupdf as fitz
from PIL import Image, ImageDraw


def inspect(pdf, output):
    output.mkdir(parents=True, exist_ok=True)
    doc = fitz.open(pdf)
    records, thumbs = [], []
    for i, page in enumerate(doc):
        spans = [dict(s, bbox=list(s['bbox']), origin=list(s['origin']))
                 for b in page.get_text('dict')['blocks'] if 'lines' in b
                 for line in b['lines'] for s in line['spans']]
        records.append({'page': i+1, 'size': list(page.rect), 'text': page.get_text(),
                        'fonts': page.get_fonts(), 'spans': spans,
                        'links': [dict(l, from_rect=list(l['from'])) for l in page.get_links()]})
        pix = page.get_pixmap(matrix=fitz.Matrix(1.5, 1.5), alpha=False)
        pix.save(output/f'page-{i+1:03}.png')
        thumb = Image.frombytes('RGB', (pix.width, pix.height), pix.samples)
        thumb.thumbnail((298, 421))
        tile = Image.new('RGB', (310, 450), 'white')
        tile.paste(thumb, ((310-thumb.width)//2, 24))
        ImageDraw.Draw(tile).text((8, 5), f'{pdf.stem} / {i+1}', fill='black')
        thumbs.append(tile)
    for start in range(0, len(thumbs), 12):
        group = thumbs[start:start+12]
        sheet = Image.new('RGB', (310*4, 450*((len(group)+3)//4)), '#dddddd')
        for j, thumb in enumerate(group):
            sheet.paste(thumb, ((j%4)*310, (j//4)*450))
        sheet.save(output/f'contact-{start//12+1:02}.png')
    (output/'pages.json').write_text(json.dumps(records, ensure_ascii=False, indent=2, default=str), encoding='utf-8')
    (output/'text.txt').write_text('\n'.join(f'--- PDF page {p["page"]} ---\n{p["text"]}' for p in records), encoding='utf-8')
    print(f'{pdf}: {len(doc)} pages -> {output}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('pdf', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    inspect(args.pdf, args.output)
