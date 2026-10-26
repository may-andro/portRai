# Storybook

A [Widgetbook](https://www.widgetbook.io/) web app that showcases the foundations and components
of the [design_system](../../layer/design_system/README.md) layer, with knobs to change their
properties and addons to switch theme, viewport and text scale.

**Live URL:** https://portrai-storybook.web.app

## Features

- Foundation use cases: color schemes (brand, surface, accent pairs, outline, utility, neutral,
  semantic), `DSRadius`, `DSSpace`, `DSElevation` and `DSTextStyle`
- Component use cases grouped as atoms, molecules and organisms, such as buttons, text fields,
  tags, cards, dialogs and bullet point lists
- Knobs on most use cases (all components except the dialogs, and the dimension foundations) for
  properties such as colors, text, sizes and flags
- Theme addon with a light and a dark theme for each of the 12 `DesignSystem` themes
- Viewport addon with no frame or any of Widgetbook's iOS and Android device viewports
- Text scale addon
- App bar with the design system logo and the app version from `package_info_plus`

## Getting Started

### Prerequisites

The Flutter, Dart and Melos versions in the root
[Getting Started](../../README.md#getting-started) section.

### Installation

```bash
# From the workspace root
melos bootstrap
```

## Architecture

Storybook's code uses `design_system`, Widgetbook and `package_info_plus`. `main.dart` builds `Widgetbook.material`
with the generated `directories`, a home screen and the addons, and wraps each use case in
`DSThemeBuilderWidget` for the selected theme and brightness. See the root
[Architecture](../../README.md#architecture) section for the layer structure.

```text
lib/
├── main.dart                     # StorybookApp: Widgetbook, addons and themes
├── main.directories.g.dart       # Generated use case tree
└── src/
    ├── foundation/               # color, dimen and typography use cases
    ├── component/
    │   ├── atom/
    │   ├── molecule/
    │   └── organism/
    ├── extensions/               # BuildContext helpers shared by use cases
    └── widget/                   # HomeScreen
```

## Development

### Running the App

The app has a web target only:

```bash
cd app/storybook
flutter run -d chrome
```

### Adding a Use Case

1. Add a `*_use_case.dart` file under `lib/src/foundation/` or
   `lib/src/component/{atom|molecule|organism}/`.
2. Annotate a builder function with `@UseCase`, naming the widget type it shows.
3. Regenerate `main.directories.g.dart` (see [Code Generation](#code-generation)).

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import '../../extensions/extensions.dart';

@UseCase(name: 'Divider', type: DSHorizontalDividerWidget)
Widget buildDivider(BuildContext context) {
  final colorMap = context.brandColorsMap;
  final colorName = context.knobs.object.dropdown(
    label: 'Color',
    options: colorMap.keys.toList(),
  );

  return Center(
    child: DSHorizontalDividerWidget(thickness: 1, color: colorMap[colorName]!),
  );
}
```

Dialog use cases read theme values from the use case `context` before calling `showDialog` and
use those values inside the dialog builder.

### Extensions

`lib/src/extensions/widgetbook_extensions.dart` defines `BuildContext` helpers that map labels to
design system values for knob options:

| Helper                                               | Values                                         |
| ---------------------------------------------------- | ---------------------------------------------- |
| `brandColorsMap`                                     | Brand colors                                   |
| `semanticColorsMap`                                  | Error, success, warning and info colors        |
| `surfaceColorsMap`                                   | Surface colors                                 |
| `neutralColorsMap`                                   | White, grey 1 to 10 and black                  |
| `allColorsMap`                                       | All of the above plus the outline colors       |
| `containerColorsMap`, `getContainerTextColor`        | Container backgrounds and their text colors    |
| `typographyStylesMap`, `allTypographyStyles`         | The 15 `DSTextStyle` levels                    |
| `elevationOptionsMap`                                | Elevation none and levels 1 to 3               |
| `radiusOptionsMap`                                   | Radius levels 1 to 3 and circular              |
| `CommonIcons.commonIcons`                            | A list of 20 Material icons                    |

### Code Generation

`widgetbook_generator` writes `lib/main.directories.g.dart` from the `@UseCase` and `@App`
annotations. The file is committed.

```bash
# From the workspace root
melos run gen --scope=storybook

# Or from app/storybook
dart run build_runner build
```

### Testing

`test/widget_test.dart` checks that `StorybookApp` renders a `Widgetbook`.

```bash
cd app/storybook
flutter test
```

## Configuration

`firebase.json` serves `build/web` on the `storybook` hosting target, rewrites every path to
`index.html`, caches JS and CSS files for a year as immutable, and sends `index.html` with
`no-cache`. `.firebaserc` maps the target to the `portrai-storybook` site in the `portrai-96f2b`
project.

## Deployment

Three workflows build and deploy the storybook. Each runs `_storybook_quality.yaml` first (format
check, `flutter analyze` and `flutter test --exclude-tags golden --coverage`), then builds with
`_build_web.yaml` in release mode after code generation, then deploys with
`_deploy_firebase.yaml` to the `storybook` hosting target.

| Workflow                   | Trigger                                                          | Hosting channel |
| -------------------------- | ---------------------------------------------------------------- | --------------- |
| `storybook_pr.yaml`        | Pull request changing `app/storybook/**`, `layer/design_system/**`, the storybook workflows or the `setup-flutter-module` action | `preview`       |
| `storybook_review.yaml`    | Tag matching `*+*-review-storybook`                              | `review`        |
| `storybook_production.yaml`| Tag matching `*+*-prod-storybook`                                | `live`          |

On pull requests, the Firebase Hosting deploy action comments the preview URL on the PR.

```bash
git tag 1.0.0+1-review-storybook
git push origin 1.0.0+1-review-storybook

git tag 1.0.0+1-prod-storybook
git push origin 1.0.0+1-prod-storybook
```

The production workflow also runs `_storybook_release_notes.yaml`, which creates a GitHub release
named `Storybook <tag>` listing the commit subjects since the previous `*+*-prod-storybook` tag.

### Manual Deploy

```bash
melos run deploy_widgetbook
```

The script runs `flutter clean`, `flutter pub get` and `flutter build web --release` in
`app/storybook`, then `firebase deploy --only hosting:storybook`.

## Contributing

See the root [Contributing](../../README.md#contributing) section.
