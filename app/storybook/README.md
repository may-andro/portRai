# PortRai Design System Storybook

Interactive component library for exploring and documenting the PortRai Design System, built with [Widgetbook](https://www.widgetbook.io/).

## Quick Start

```bash
# From project root
melos bootstrap

# Run storybook
cd app/storybook
flutter run -d chrome
```

## What's Inside

An interactive showcase of design system components following Atomic Design:
- **Atoms** - Basic building blocks (buttons, text, icons, cards, etc.)
- **Molecules** - Component combinations (text fields, tags, chips, etc.)
- **Organisms** - Complex patterns (dialogs, lists, forms, etc.)

Each component has interactive knobs for real-time property adjustment.

## Key Features

- 🎨 Multiple cultural theme variants
- 🎛️ Interactive property controls
- 📱 Responsive device preview
- 🌗 Light/dark mode toggle
- 🧩 Global extension system for consistency

## Development

### Adding a Component

1. Create a use case file in `lib/src/component/{atom|molecule|organism}/`
2. Use `@UseCase` annotation and global extensions
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`

Example:
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

- ✅ Use global extensions instead of hardcoded values
- ✅ Add knobs for all configurable properties
- ✅ Capture theme values before `showDialog` calls
- ✅ Test across multiple themes

### Building for Production

```bash
flutter build web --release
```

## Project Structure

```
lib/
├── src/
│   ├── component/        # Use cases (atoms, molecules, organisms)
│   └── extensions/       # Global helpers
└── main.dart
```

## Links

- [Extension Guide](lib/src/extensions/README.md)
- [Design System](../../layer/design_system/)
- [Widgetbook Docs](https://docs.widgetbook.io/)
