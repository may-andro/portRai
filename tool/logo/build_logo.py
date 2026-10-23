"""Builds the polished logo SVG from the potrace trace of the original.

The trace gives smooth vector outlines of the original shapes; the colour is
rebuilt as one clean navy-to-teal gradient fitted to the original pixels
(least-squares fit: about 20 degrees, navy lower left to teal upper right), so there is no
palette banding and no soft halo on the edges.

Usage: build_logo.py <traced.svg> <out.svg> <content_radius_fraction> [background]
  content_radius_fraction: furthest point of the mark from the centre, as a
  fraction of the canvas size (the original files use 0.39).
"""
import re
import sys

traced, out, frac = sys.argv[1], sys.argv[2], float(sys.argv[3])
bg = sys.argv[4] if len(sys.argv) > 4 else None

ORIGINAL_FRAC = 0.39  # where the trace sits in its own canvas

src = open(traced).read()
group = re.search(r"<g transform=\"([^\"]+)\"[^>]*>(.*)</g>", src, re.S)
inner_transform, paths = group.group(1), group.group(2)
paths = re.sub(r"\s+", " ", paths).replace(' fill="#000000"', "")

k = frac / ORIGINAL_FRAC
svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2048 2048" width="2048" height="2048">
<defs>
<linearGradient id="g" gradientUnits="userSpaceOnUse" x1="350" y1="1271" x2="1718" y2="769">
<stop offset="0" stop-color="#1A3A6C"/><stop offset=".5" stop-color="#1D7691"/><stop offset="1" stop-color="#27A9A3"/>
</linearGradient>
<mask id="m" maskUnits="userSpaceOnUse" x="-2048" y="-2048" width="6144" height="6144">
<g transform="scale(.5)">
<g transform="{inner_transform}" fill="#fff">{paths}</g></g>
</mask>
</defs>
{f'<rect width="2048" height="2048" fill="{bg}"/>' if bg else ''}
<g transform="translate(1024 1024) scale({k:.5f}) translate(-1024 -1024)">
<rect x="-2048" y="-2048" width="6144" height="6144" fill="url(#g)" mask="url(#m)"/></g>
</svg>
"""
open(out, "w").write(svg)
