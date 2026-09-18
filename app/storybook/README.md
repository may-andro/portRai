# PortRai Design System Storybook

Interactive component library for exploring and documenting the PortRai Design System, built with
[Widgetbook](https://www.widgetbook.io/).

**Live URL:** https://portrai-storybook.web.app

## Features

An interactive showcase of design system components following Atomic Design:
- **Atoms** - Basic building blocks (buttons, text, icons, cards, etc.)
- **Molecules** - Component combinations (text fields, tags, chips, etc.)
- **Organisms** - Complex patterns (dialogs, lists, forms, etc.)
- Interactive knobs for real-time property adjustment on every component
- Multiple cultural theme variants
- Responsive device preview
- Light/dark mode toggle
- Global extension system for consistency across use cases

## Getting Started

### Installation
```bash
# From project root
melos bootstrap

# Run storybook in Chrome
cd app/storybook
flutter run -d chrome
```

## Architecture

```text
lib/
├── src/
│   ├── component/        # Use cases (atoms, molecules, organisms)
│   └── extensions/       # Global helpers
└── main.dart
```

## Development

### Adding a Component
1. Create a use case file in `lib/src/component/{atom|molecule|organism}/`
2. Use `@UseCase` annotation and global extensions
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`

```dart
import 'package:design_system/design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'My Widget', type: MyWidget)
Widget buildMyWidget(BuildContext context) {
  final colorMap = context.brandColorsMap;
  final color = colorMap[context.knobs.object.dropdown(
    label: 'Color',
    options: colorMap.keys.toList(),
  )]!;

  return Center(child: MyWidget(color: color));
}
```

### Global Extensions
Centralized helpers to avoid duplication:

```dart
context.brandColorsMap          // Brand colors
context.semanticColorsMap       // Error, Success, Warning, Info
context.typographyStylesMap     // Text styles
context.elevationOptionsMap     // Elevation levels
context.radiusOptionsMap        // Border radius options
CommonIcons.commonIcons         // Icon set
```

See [extension documentation](lib/src/extensions/README.md) for details.

### Best Practices
- Use global extensions instead of hardcoded values
- Add knobs for all configurable properties
- Capture theme values before `showDialog` calls
- Test across multiple themes

## Deployment

Three CI workflows handle storybook deployments automatically.

### PR Preview - `storybook_pr.yaml`
Triggers on every pull request that touches `app/storybook/**` or `layer/design_system/**`.

| Step | Action |
|---|---|
| Quality | Format, analysis, tests |
| Build | Flutter web (preview) |
| Deploy | Firebase Hosting -> `preview` channel |

The preview URL is posted as a comment on the PR.

### Review Release - `storybook_review.yaml`
Triggers on tags matching `*+*-review-storybook` (e.g. `1.0.0+1-review-storybook`).

```bash
git tag 1.0.0+1-review-storybook
git push origin 1.0.0+1-review-storybook
```

Deploys to the `review` channel - useful for stakeholder sign-off before production.

### Production Release - `storybook_production.yaml`
Triggers on tags matching `*+*-prod-storybook` (e.g. `1.0.0+1-prod-storybook`).

```bash
git tag 1.0.0+1-prod-storybook
git push origin 1.0.0+1-prod-storybook
```

| Step | Action |
|---|---|
| Quality | Format, analysis, tests |
| Build | Flutter web (release) |
| Deploy | Firebase Hosting -> `live` channel |

**Live URL after deploy:** https://portrai-storybook.web.app

### Manual Deploy (without CI)
```bash
melos deploy_widgetbook
```

Or manually from this directory:
```bash
flutter build web --release
firebase deploy --only hosting:storybook
```

## Contributing

See the root [Contributing](../../README.md#contributing) section for the development workflow,
code style, and branch/PR conventions.

## Links
- [Extension Guide](lib/src/extensions/README.md)
- [Design System](../../layer/design_system/)
- [Widgetbook Docs](https://docs.widgetbook.io/)
- [Firebase Console](https://console.firebase.google.com/project/portrai-96f2b/hosting)
