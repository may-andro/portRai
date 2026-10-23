# Logo

Vector source of the PortRai "MR" logo and the script that exports every logo image the apps
use, then regenerates the platform launcher icons and native splash screens.

## Features

- Keeps the logo as smooth vector outlines with one navy-to-teal gradient, so every export has
  clean edges at any size.
- Exports all logo images from one source, each at its expected size and placement.
- Regenerates the Android, iOS and web launcher icons and splash screens in the same run.

## Files

| File             | Purpose                                                                    |
| ---------------- | -------------------------------------------------------------------------- |
| `logo_trace.svg` | Outlines of the logo shapes, without colour                                |
| `build_logo.py`  | Fills the outlines with the gradient and scales them to a given placement  |
| `render_logo.sh` | Renders an SVG to a PNG of a given size with headless Chrome               |
| `export_logo.sh` | Builds and renders every image below, then runs both platform generators   |
| `logo.svg`       | The finished logo with a transparent background, for design tools          |

## Exported images

| Image                                             | Size | Background  | Content radius |
| ------------------------------------------------- | ---- | ----------- | -------------- |
| `layer/design_system/assets/image/logo.png`       | 2048 | Transparent | 39%            |
| `app/portrai/assets/launcher/logo.png`            | 2048 | Transparent | 39%            |
| `app/portrai/assets/launcher/logo-ios.png`        | 2048 | White       | 39%            |
| `app/portrai/assets/splash/logo.png`              | 1024 | Transparent | 39%            |
| `app/portrai/assets/splash/logo_android12.png`    | 1152 | Transparent | 30%            |

The content radius is the furthest point of the logo from the centre, as a share of the image
size. The Android 12 splash icon uses 30% because Android shows only a centred circle of two
thirds of that image. The iOS icon has no alpha channel, as the App Store requires.

## Getting Started

### Prerequisites

- Python 3
- Google Chrome, used headless for rendering
- ImageMagick (`magick`), to remove the alpha channel from the iOS icon
- Flutter, for `flutter_launcher_icons` and `flutter_native_splash`

## Usage

Run from the repository root after changing `logo_trace.svg` or the gradient in
`build_logo.py`:

```bash
tool/logo/export_logo.sh
```

The script reads `app/portrai/flutter_launcher_icons.yaml` and `app/portrai/native_splash.yaml`.
`flutter_native_splash` also rewrites `ios/Runner/Info.plist` and `web/index.html`; review
their diff and revert changes that only reformat them.

To export a single image, build the SVG with a content radius and an optional background, then
render it:

```bash
python3 tool/logo/build_logo.py tool/logo/logo_trace.svg /tmp/logo.svg 0.39 '#FFFFFF'
tool/logo/render_logo.sh /tmp/logo.svg /tmp/logo.png 1024
```

## Testing

Compare the exported images with the previous ones in the diff, and check the launcher icon and
splash screen on a device or emulator for each platform.
