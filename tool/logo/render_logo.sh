#!/bin/zsh
# render_logo.sh <in.svg> <out.png> <px>: renders the SVG to a px-by-px PNG with headless Chrome.
set -e
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
tmp=$(mktemp -d)
print -r -- "<html><body style='margin:0'><img src='file://$1' style='display:block;width:1024px;height:1024px'></body></html>" > $tmp/page.html
"$CH" --headless --disable-gpu --hide-scrollbars --default-background-color=00000000 \
  --force-device-scale-factor=$(( $3 / 1024.0 )) --window-size=1024,1024 --user-data-dir=$tmp/chrome \
  --screenshot=$2 "file://$tmp/page.html" >/dev/null 2>&1
rm -rf $tmp
