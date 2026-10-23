#!/bin/zsh
# Exports every logo PNG the app uses from the vector source, then
# regenerates the platform launcher icons and native splash screens.
#
#   logo_trace.svg  smooth outlines traced from the original artwork (potrace)
#   build_logo.py   applies the navy-to-teal gradient and the placement
#   render_logo.sh  renders an SVG to PNG with headless Chrome
#
# Usage: tool/logo/export_logo.sh   (from the repository root)
set -e
cd "${0:A:h}"
root=../..
app=$root/app/portrai
tmp=$(mktemp -d)

python3 build_logo.py logo_trace.svg $tmp/logo.svg 0.39
python3 build_logo.py logo_trace.svg $tmp/logo_ios.svg 0.39 '#FFFFFF'
# Android 12 splash icons must fit a circle of 2/3 of the canvas.
python3 build_logo.py logo_trace.svg $tmp/logo_android12.svg 0.30

./render_logo.sh $tmp/logo.svg $root/layer/design_system/assets/image/logo.png 2048
./render_logo.sh $tmp/logo.svg $app/assets/launcher/logo.png 2048
./render_logo.sh $tmp/logo_ios.svg $tmp/logo_ios.png 2048
magick $tmp/logo_ios.png -background white -alpha remove -alpha off $app/assets/launcher/logo-ios.png
./render_logo.sh $tmp/logo.svg $app/assets/splash/logo.png 1024
./render_logo.sh $tmp/logo_android12.svg $app/assets/splash/logo_android12.png 1152
rm -rf $tmp

cd $app
dart run flutter_launcher_icons
dart run flutter_native_splash:create --path=native_splash.yaml
