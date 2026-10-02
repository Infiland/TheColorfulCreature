#!/usr/bin/env python3
"""Render the unchanged Lunar Base source map for route review, without simulation.

The SVG shows authored positions and initial geometry only. Moving hazards,
troops, breakables and key gates need native runtime verification.
"""
import argparse
from collections import Counter
from functools import lru_cache
import hashlib
import html
import json
from pathlib import Path

from tcc_project import ROOT, read_yy

SOURCE = ROOT / 'datafiles/Challenges/Lunar Base Challenge/1/LevelEditor.sav'
PALETTE = {'white': '#d0d7e2', 'red': '#e7666a', 'yellow': '#e8c858',
           'green': '#65bf88', 'blue': '#659fd4', 'ice': '#97dce6'}


@lru_cache(None)
def object_data(name):
    return read_yy(ROOT / 'objects' / name / f'{name}.yy')


@lru_cache(None)
def sprite_data(name):
    return read_yy(ROOT / 'sprites' / name / f'{name}.yy')


def initial_bounds(entry):
    name = entry['obj']
    # LE wrappers author one runtime object at the same position, with 1x scale
    # in this map. Use that object's sprite so troop/hazard extents are visible.
    runtime = name[:-2] if name.endswith('LE') else name
    if not (ROOT / 'objects' / runtime / f'{runtime}.yy').exists():
        runtime = name
    obj = object_data(runtime)
    spr = obj.get('spriteMaskId') or obj.get('spriteId')
    if spr:
        data = sprite_data(spr['name'])
        xo, yo = data['sequence']['xorigin'], data['sequence']['yorigin']
        x1 = entry['x'] + (data['bbox_left'] - xo) * entry['xscale']
        x2 = entry['x'] + (data['bbox_right'] + 1 - xo) * entry['xscale']
        y1 = entry['y'] + (data['bbox_top'] - yo) * entry['yscale']
        y2 = entry['y'] + (data['bbox_bottom'] + 1 - yo) * entry['yscale']
        return [min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)]
    return [entry['x'], entry['y'], entry['x'] + 32, entry['y'] + 32]


def category(name):
    if 'background' in name:
        return 'background'
    if name in ['o_playerspawner', 'o_door'] or any(s in name for s in ('itemLE', 'speed', 'gravity', 'gunLE', 'ammoLE', 'keyLE')):
        return 'pickup'
    if any(s in name for s in ('spike', 'shooter', 'rocketlauncher', 'enemyplayer', 'lava')):
        return 'hazard'
    return 'geometry'


def colour(name):
    if 'lava' in name:
        return '#f1893f'
    if 'deathblock' in name or 'spike' in name:
        return '#d458b6'
    if 'enemy' in name:
        return '#c7f163'
    if 'shooter' in name or 'launcher' in name:
        return '#e08d55'
    if 'unlocked' in name:
        return '#b787de'
    if 'ladder' in name or 'box' in name:
        return '#ba9068'
    for key, value in PALETTE.items():
        if key in name:
            return value
    return '#f0f1f4'


def label(name):
    fixed = {'o_playerspawner': 'S', 'o_door': 'EXIT', 'o_gunLE': 'GUN',
             'o_ammoLE': 'AMMO', 'o_keyLE': 'KEY'}
    if name in fixed:
        return fixed[name]
    if 'itemLE' in name:
        return name[2].upper()
    if 'speed5' in name:
        return '2.8'
    if 'speed7' in name:
        return '4.0'
    if 'gravity05' in name:
        return '.172'
    if 'gravity15' in name:
        return '.5'
    return ''


def render(entries, output, route=None, crop=None, title='Lunar Base — authored geometry, unverified route'):
    left, top, right, bottom = crop or (0, 0, 3200, 3264)
    margin = 64
    width, height = right - left, bottom - top
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{left-margin} {top-128} {width+margin*2} {height+192}">',
           '<style>text {font-family:Arial,sans-serif;fill:#f2f4f7} .grid {stroke:#283344;stroke-width:1} .item-label {font-size:19px;font-weight:bold;paint-order:stroke;stroke:#101722;stroke-width:5;stroke-linejoin:round}</style>',
           f'<rect x="{left-margin}" y="{top-128}" width="{width+margin*2}" height="{height+192}" fill="#101722"/>',
           f'<text x="{left}" y="{top-70}" font-size="35">{html.escape(title)}</text>',
           f'<text x="{left}" y="{top-25}" font-size="22">32 px grid · hover objects for source order/coordinates · initial hazard positions only</text>',
           f'<clipPath id="map"><rect x="{left}" y="{top}" width="{width}" height="{height}"/></clipPath>',
           '<g clip-path="url(#map)">']
    for x in range(int(left // 320) * 320, int(right) + 1, 320):
        svg.append(f'<path class="grid" d="M{x} {top}V{bottom}"/>')
    for y in range(int(top // 320) * 320, int(bottom) + 1, 320):
        svg.append(f'<path class="grid" d="M{left} {y}H{right}"/>')
    for wanted in ('background', 'geometry', 'hazard', 'pickup'):
        svg.append(f'<g id="{wanted}">')
        for i, e in enumerate(entries):
            if category(e['obj']) != wanted:
                continue
            x1, y1, x2, y2 = initial_bounds(e)
            if x2 < left or x1 > right or y2 < top or y1 > bottom:
                continue
            c = colour(e['obj'])
            desc = html.escape(f"#{i}: {e['obj']} at ({e['x']:g},{e['y']:g}); scale ({e['xscale']:g},{e['yscale']:g})")
            if wanted == 'pickup':
                cx, cy = e['x'] + 16, e['y'] + 16
                svg.append(f'<g><title>{desc}</title><circle cx="{cx}" cy="{cy}" r="15" fill="{c}" stroke="#101722" stroke-width="3"/><text class="item-label" x="{cx+17}" y="{cy+6}">{label(e["obj"])}</text></g>')
                continue
            opacity = '.10' if wanted == 'background' else ('0.78' if wanted == 'hazard' else '1')
            stroke = '#101722' if wanted != 'background' else c
            dash = ' stroke-dasharray="5 3"' if ('breakable' in e['obj'] or 'passblock' in e['obj']) else ''
            if 'passblock' in e['obj']:
                opacity = '.23'
            svg.append(f'<g><title>{desc}</title><rect x="{x1:g}" y="{y1:g}" width="{x2-x1:g}" height="{y2-y1:g}" fill="{c}" fill-opacity="{opacity}" stroke="{stroke}" stroke-width="1.5"{dash}/></g>')
            if 'breakable' in e['obj']:
                svg.append(f'<path d="M{x1+5:g} {y1+5:g}L{x2-5:g} {y2-5:g}" stroke="#647083" stroke-width="2"/>')
        svg.append('</g>')
    if route:
        for section in route.get('sections', []):
            points = section.get('mapPolyline', [])
            if points:
                points_text = ' '.join(f'{x},{y}' for x, y in points)
                svg.append(f'<polyline points="{points_text}" fill="none" stroke="#f8f9fa" stroke-width="7" opacity=".78" stroke-dasharray="14 10"><title>{html.escape(section["title"])} — route hypothesis, not a collision-free trajectory</title></polyline>')
            for marker in section.get('markers', []):
                x, y = marker['x'], marker['y']
                text = html.escape(marker['id'])
                svg.append(f'<g><title>{html.escape(marker["label"])}</title><circle cx="{x}" cy="{y}" r="23" fill="#0b151f" stroke="#f4f6fb" stroke-width="3"/><text x="{x}" y="{y+8}" text-anchor="middle" font-size="23" font-weight="bold">{text}</text></g>')
    svg.append('</g>')
    for x in range(int(left // 320) * 320, int(right) + 1, 320):
        svg.append(f'<text x="{x}" y="{bottom+35}" text-anchor="middle" font-size="21">{x}</text>')
    for y in range(int(top // 320) * 320, int(bottom) + 1, 320):
        svg.append(f'<text x="{left-12}" y="{y+7}" text-anchor="end" font-size="20">{y}</text>')
    svg.append('</svg>')
    output.write_text('\n'.join(svg) + '\n')


def render_png(entries, output, route=None, crop=None):
    """Optional raster export of the source-data chart; Pillow is bundled by Codex."""
    from PIL import Image, ImageDraw, ImageFont
    left, top, right, bottom = crop or (0, 0, 3200, 3264)
    factor = min(1, 1600 / max(right-left, bottom-top))
    margin = 48
    im = Image.new('RGB', (round((right-left)*factor)+margin*2,
                          round((bottom-top)*factor)+margin*2), '#101722')
    draw = ImageDraw.Draw(im)
    font_path = '/System/Library/Fonts/Supplemental/Arial.ttf'
    font = ImageFont.truetype(font_path, 13) if Path(font_path).exists() else ImageFont.load_default()
    def point(x, y):
        return (margin+(x-left)*factor, margin+(y-top)*factor)
    for x in range(int(left//320)*320, int(right)+1, 320):
        draw.line([point(x, top), point(x, bottom)], fill='#283344')
        draw.text(point(x, bottom+12), str(x), font=font, fill='white')
    for y in range(int(top//320)*320, int(bottom)+1, 320):
        draw.line([point(left, y), point(right, y)], fill='#283344')
        draw.text((4, point(left, y)[1]), str(y), font=font, fill='white')
    for want in ('geometry', 'hazard', 'pickup'):
        for e in entries:
            if category(e['obj']) != want:
                continue
            x1, y1, x2, y2 = initial_bounds(e)
            if x2 < left or x1 > right or y2 < top or y1 > bottom:
                continue
            box = [point(x1, y1), point(x2, y2)]
            c = colour(e['obj'])
            if want == 'pickup':
                draw.ellipse(box, fill=c, outline='black')
                draw.text((box[0][0]+2, box[0][1]-15), label(e['obj']), font=font,
                          fill='white', stroke_width=1, stroke_fill='#101722')
            elif 'passblock' in e['obj']:
                draw.rectangle(box, outline=c, width=2)
            else:
                draw.rectangle(box, fill=c, outline='#101722')
                if 'breakable' in e['obj']:
                    draw.line(box, fill='#647083')
    if route:
        for section in route.get('sections', []):
            points = section.get('mapPolyline', [])
            if points:
                draw.line([point(x, y) for x, y in points], fill='#f6f8fb', width=2)
            for marker in section.get('markers', []):
                x, y = point(marker['x'], marker['y'])
                if not (margin <= x <= im.width-margin and margin <= y <= im.height-margin):
                    continue
                draw.ellipse((x-13, y-13, x+13, y+13), fill='#101722', outline='white', width=2)
                draw.text((x, y), marker['id'], anchor='mm', font=font, fill='white')
    draw.text((margin, 10), 'Lunar Base — source geometry; route hypothesis only', font=font, fill='white')
    im.save(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'implementation/1.3.0/lunar-route')
    parser.add_argument('--route', type=Path)
    parser.add_argument('--png', action='store_true', help='Also create raster chart previews; requires Pillow')
    args = parser.parse_args()
    source_bytes = SOURCE.read_bytes()
    entries = json.JSONDecoder().raw_decode(source_bytes.decode('utf-8'))[0]['ROOT']
    args.output.mkdir(parents=True, exist_ok=True)
    route = json.loads(args.route.read_text()) if args.route else None
    inventory = {'source': str(SOURCE.relative_to(ROOT)), 'sourceSha256': hashlib.sha256(source_bytes).hexdigest(),
                 'instanceCount': len(entries), 'counts': dict(Counter(e['obj'] for e in entries)),
                 'staticOnly': True, 'entries': [{**e, 'sourceOrder': i, 'initialBounds': initial_bounds(e), 'category': category(e['obj'])} for i, e in enumerate(entries)]}
    (args.output / 'inventory.json').write_text(json.dumps(inventory, indent=2) + '\n')
    render(entries, args.output / 'overview.svg', route)
    if args.png:
        render_png(entries, args.output / 'overview.png', route)
    for name, crop in [('01-lower', (0, 2688, 3200, 3264)), ('02-key', (0, 2240, 3200, 2752)),
                       ('03-west', (0, 1600, 1536, 2496)), ('04-upper', (0, 1120, 3200, 1792)),
                       ('05-exit', (0, 384, 2368, 1280))]:
        render(entries, args.output / f'{name}.svg', route, crop, f'Lunar Base — {name}; runtime traversal unverified')
        if args.png:
            render_png(entries, args.output / f'{name}.png', route, crop)
    print(json.dumps({k: inventory[k] for k in ('sourceSha256', 'instanceCount', 'staticOnly')}))


if __name__ == '__main__':
    main()
