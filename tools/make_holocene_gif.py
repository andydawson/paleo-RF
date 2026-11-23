#!/usr/bin/env python3
"""Join the frames of tools/animate_holocene.R into one GIF.

Needs Python 3 with Pillow (no animation package or encoder is installed for R).
Run from the repository root, after the R step:
    python3 tools/make_holocene_gif.py figures/animations

Reads <folder>/frames.csv for the frame order, files and display durations, and
writes <folder>/holocene_nadi_april.gif. A GIF holds at most 256 colours, so all
frames are reduced to one shared palette, built from small copies of every frame,
so that a colour means the same value in every frame. Any failure stops with a
non-zero exit status, so an old GIF is never left looking current without notice.
"""
import csv
import sys
from pathlib import Path

from PIL import Image

if len(sys.argv) != 2:
    sys.exit('usage: python3 tools/make_holocene_gif.py <folder>')
base = Path(sys.argv[1])
with (base / 'frames.csv').open() as f:
    rows = list(csv.DictReader(f))

swatches = Image.new('RGB', (240, 105 * len(rows)), 'white')
for i, row in enumerate(rows):
    with Image.open(base / 'frames' / row['file']) as im:
        swatches.paste(im.convert('RGB').resize((240, 105)), (0, 105 * i))
palette = swatches.quantize(colors=256)

indexed = []
for row in rows:
    with Image.open(base / 'frames' / row['file']) as im:
        indexed.append(im.convert('RGB').quantize(palette=palette, dither=Image.Dither.NONE))
duration = [int(row['duration_ms']) for row in rows]
indexed[0].save(base / 'holocene_nadi_april.gif', save_all=True, append_images=indexed[1:],
                duration=duration, loop=0, disposal=2, optimize=False)
print(f'GIF: {len(indexed)} frames, {indexed[0].size}, {sum(duration) / 1000:.1f} seconds')
