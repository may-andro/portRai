"""Builds a logo SVG from the outlines in logo_trace.svg.

The outlines are filled with one linear gradient that runs at about 20
degrees, navy at the lower left to teal at the upper right, then scaled
about the centre to the requested placement.

Usage: build_logo.py <logo_trace.svg> <out.svg> <content_radius_fraction> [background]
  content_radius_fraction: furthest point of the logo from the centre, as a
  fraction of the canvas size (0.39 for most images).
"""
import re
import sys

traced, out, frac = sys.argv[1], sys.argv[2], float(sys.argv[3])
bg = sys.argv[4] if len(sys.argv) > 4 else None

TRACE_FRAC = 0.39  # where the trace sits in its own canvas

src = open(traced).read()
group = re.search(r"<g transform=\"([^\"]+)\"[^>]*>(.*)</g>", src, re.S)
inner_transform, paths = group.group(1), group.group(2)
paths = re.sub(r"\s+", " ", paths).replace(' fill="#000000"', "")

k = frac / TRACE_FRAC
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
