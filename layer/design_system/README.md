# Design System

Themed Flutter widgets organized as atoms, molecules and organisms, plus the color, dimension and
typography tokens of 12 design systems, each with a light and a dark palette.

## Features

- Atom, molecule and organism widgets, all prefixed `DS`
- 12 design systems, each with light and dark color palettes, typography and dimensions
- `BuildContext` extensions for theme tokens, responsive spacing and breakpoints
- Lottie-based animated icons and illustrations recolored from the active theme
- Golden tests for the widgets across every design system and both brightnesses

## Getting Started

### Installation

The package is part of the workspace:

```yaml
dependencies:
  design_system: any
```

```dart
import 'package:design_system/design_system.dart';
```

`design_system.dart` exports every component, the `DesignSystem` enum, the foundation tokens,
the theme classes, the `BuildContext` extensions and `package:flutter_animate`.

The layer has no `ModuleConfigurator`.

## Usage

### Applying a Theme

```dart
DSThemeBuilderWidget(
  designSystem: DesignSystem.sakura,
  brightness: Brightness.light,
  child: child,
)
```

`DSThemeBuilderWidget` provides the `DSTheme` to its subtree, applies a Material 3 `ThemeData`
whose `ColorScheme` is built from the active palette, and clamps text scaling between 0.75 and
1.5.

### Reading Theme Values from `BuildContext`

```dart
context.theme                        // DSTheme
context.colorPalette.brand.primary   // DSColor; .color gives the Flutter Color
context.typography.titleLarge        // DSTextStyle
context.dimen.radiusLevel2           // DSRadius

// factor * (grid + 0 on mobile, 4 on tablet, 8 on desktop) * text scale
context.space(factor: 2)

context.deviceResolution             // DSDeviceResolution.mobile | tablet | desktop
context.isDesktop
context.screenHorizontalPadding      // space(3) mobile, space(5) tablet, 15% of width desktop
context.showSnackBar(snackBar: const DSSnackBar(message: 'Saved', type: DSSnackBarType.success));
```

### Using Components

```dart
DSButtonWidget(
  label: 'Continue',
  onPressed: onContinue,
  variant: DSButtonVariant.secondary,
  size: DSButtonSize.medium,
)

DSTextWidget(
  'Title',
  color: context.colorPalette.surface.onSurface,
  style: context.typography.titleLarge,
)
```

## Key Concepts

### Architecture

```text
lib/src/
├── component/
│   ├── atom/        # Single-purpose widgets (button, text, icon, card, Lottie, ...)
│   ├── molecule/    # Widgets composed of atoms (app bar, tag, text field, ...)
│   └── organism/    # Larger compositions (dialog, error card, carousel, ...)
├── design_system/   # One folder per DesignSystem value: color, dimen, typography
├── extension/       # BuildContext and DSColorPalette extensions
├── foundation/      # Token types: color, dimen, typography
└── theme/           # DSTheme and DSThemeBuilderWidget
```

Each component level has a barrel file (`atom.dart`, `molecule.dart`, `organism.dart`).

### Components

#### Atoms

| Widget | Description |
|--------|-------------|
| `DSButtonWidget` | Button with `primary`, `secondary`, `error` and `text` variants, `regular` or `rounded` border, 4 sizes (`extraSmall` to `large`), optional icon, loading and disabled states |
| `DSIconButtonWidget` | Icon-only button with 3 sizes, optional elevation and loading state |
| `DSTextWidget` | Text in a `DSTextStyle` and `DSColor`, with italic, decoration, alignment and overflow options |
| `DSIconWidget` | Icon in `small`, `medium` or `large` size |
| `DSCardWidget` | Card with optional tap, radius, elevation, margin and background opacity |
| `DSHorizontalDividerWidget` | Horizontal divider with a thickness and color |
| `DSVerticalDividerWidget` | Vertical divider with a thickness and color |
| `DSHorizontalSpacerWidget` | Horizontal gap of `context.space(factor: factor)` |
| `DSVerticalSpacerWidget` | Vertical gap of `context.space(factor: factor)` |
| `DSLoadingWidget` | Loading indicator: staggered dots (`DSLoadingStyle.dots`) or a recolored Lottie loader (`DSLoadingStyle.lottie`) |
| `DSResponsiveContainerWidget` | Builds a different child for mobile, tablet and desktop |
| `DSResponsiveWidthContainerWidget` | Builds a different child for the `xs`, `s`, `m`, `l` and `xl` window widths |
| `DSVisibilityDetectorWidget` | Calls back when the child's visibility in the viewport changes |
| `DSOffscreenPauseWidget` | Pauses the child's animations while none of it is on screen |
| `DSCircularLogoWidget` | The bundled logo in a circle, with `white` and `black` variants |
| `DSImage` | Static accessors for the bundled `logo` and `avatar` images |
| `DSLottieWidget` | Plays a bundled Lottie asset once visible, with color overrides |
| `DSLottieIconWidget` | Animated icon from `DSLottieIcon`, recolored to one color |
| `DSLottieIllustrationWidget` | Animated scene from `DSLottieIllustration`, recolored from the theme |
| `DSLottieBackgroundWidget` | Faded, optionally greyscale illustration that fills its parent |
| `DSLottieDataWidget` | Plays a Lottie animation given as JSON bytes |
| `DSBrandIconWidget` | Animated brand icon from `DSBrandIcon`, in the theme's brand colors |
| `DSBrandIconButtonWidget` | Circular button showing an animated brand icon |

#### Molecules

| Widget | Description |
|--------|-------------|
| `DSAppBarWidget` | App bar with the animated logo, optional back button and actions |
| `DSArchPortraitWidget` | Arched frame whose child can rise above the arch |
| `DSAvailabilityBadgeWidget` | Pill badge with a pulsing status dot |
| `DSAvatarNameWidget` | Circular network image next to a caption and a name |
| `DSDetailSectionWidget` | Title above arbitrary child content |
| `DSExpandableCardWidget` | Card that expands and collapses its content on tap |
| `DSFestiveBackdropWidget` | Animated circular or rectangular backdrop whose effect follows the active design system |
| `DSFloatingShapesBackgroundWidget` | Background of drifting rings, dots, plus signs and diamonds |
| `DSGradientBlobWidget` | Pulsing radial-gradient blob |
| `DSHoverableContainerWidget` | Builder that receives the hover state |
| `DSIconInfoTileWidget` | Gradient tile with an icon badge, a label and a value |
| `DSInfoChipWidget` | Icon and label pill in the secondary container colors |
| `DSLabeledInfoRowWidget` | Icon in a circle, label and value, with a chevron when tappable |
| `DSMapWidget` | Google Map marking `DSMapPlace`s, framed to fit them and colored from the theme; still and cheap to scroll past unless `isInteractive`, with `brand` markers and a `minimal` style without roads |
| `DSNetworkImageWidget` | Cached network image, decoded at its displayed size, that retries after the device reconnects |
| `DSPositionIndicatorWidget` | Row of dots marking the current index |
| `DSQuoteTextWidget` | Quote glyph followed by text capped at `maxLines` |
| `DSSkillCardWidget` | Card with an animated progress meter that highlights on hover |
| `DSSnackBar` | Data class converted to a `SnackBar`, with `success`, `error` and `info` types |
| `DSSpotlightCardWidget` | Tappable card with a corner glow that grows on hover |
| `DSTabItemWidget` | Tab label with selected and hover underlines |
| `DSTagWidget` | Rounded label in the primary container colors |
| `DSTextFieldWidget` | Text field with `normal` and `password` types and error, success and helper messages |
| `DSTitleDescriptionWidget` | Title and description with fixed line counts |

#### Organisms

| Widget | Description |
|--------|-------------|
| `DSBulletPointListWidget` | List of bullet points |
| `DSCarousalWidget` | Carousel built on `carousel_slider` |
| `DSDialogWidget` | Rounded dialog with an optional maximum width |
| `DSErrorCardWidget` | Error icon, title, message and optional retry button; title and retry label can be replaced |
| `DSSectionContainerWidget` | Section with a surface or inverse background, an optional animated title and action, entry animations on visibility and responsive padding |
| `DSStaggeredGridWidget` | Masonry grid built on `flutter_staggered_grid_view` |

### Theming

`DesignSystem` has 12 values:

`beltane`, `carnival`, `chuseok`, `diwali`, `halloween`, `hogeras`, `hogmanay`, `holi`, `obon`,
`pachamama`, `sakura`, `xmas`

Each value has a light and a dark `DSColorPalette`, a `DSTypography` and a `DSDimen` under
`lib/src/design_system/<name>/`. A `DSTheme` combines one `DesignSystem` with one `Brightness`.

### Foundation

| Type | Contents |
|------|----------|
| `DSColor` | A color token; `.color` returns the Flutter `Color` |
| `DSColorPalette` | `brand`, `semantic`, `neutral`, `surface`, `outline` and `utility` color schemes |
| `DSTypography` | `display`, `headline`, `title`, `body` and `label` styles in large, medium and small, each with an `emphasized` variant |
| `DSDimen` | Radius levels 1-3 and circular, elevation none and levels 1-3, and the spacing grid |

`DsColorRolesExtension` on `DSColorPalette` adds role names such as `primaryAction`, `textPrimary`,
`border` and `error`.

### Animated Icons and Illustrations

`DSLottieWidget` and the widgets built on it start playing when at least 50% of the widget is
visible (`visibilityThreshold`). `playback` takes a `DSLottiePlayback`:

- `once`: plays a single time, the first time it becomes visible
- `loop`: loops while visible and pauses when scrolled out of view
- `trigger`: stays on the first frame and plays once each time `trigger` changes

```dart
DSBrandIconWidget(brand: DSBrandIcon.linkedin, size: 24)
DSBrandIconWidget(brand: DSBrandIcon.linkedin, size: 24, playback: DSLottiePlayback.loop)
DSBrandIcon.fromName('GitHub') // null when no brand icon has that name

DSLottieIconWidget(
  icon: DSLottieIcon.paperPlane,
  size: 24,
  color: Colors.white,
  playback: DSLottiePlayback.trigger,
  trigger: sendCount,
)

DSLottieIllustrationWidget(illustration: DSLottieIllustration.contactUs, width: 200)
DSLottieBackgroundWidget(illustration: DSLottieIllustration.heroOrbs)
DSLoadingWidget(size: 24, style: DSLoadingStyle.lottie)
```

`DSBrandIconWidget` paints the brand circle with `brand.primary` and the mark with
`brand.onPrimary` unless `color` and `onColor` are given. `DSLottieIllustrationWidget` recolors
the scenes that have a theme mapping (`useThemeColors`, on by default); `colorOverrides` apply on
top.

To add a brand icon: put the Lottie JSON in `assets/lottie/`, regenerate the asset accessors with
`dart run build_runner build` (flutter_gen writes `lib/assets/assets.gen.dart`), and add a
`DSBrandIcon` value with its asset and color overrides, given as layer key paths such as
`['circle behind Logo', '**', 'Fill 1']`.

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_animate` | Animations; re-exported by `design_system.dart` |
| `adaptive_breakpoints` | Window size classes behind `deviceResolution` and `deviceWidth` |
| `lottie` | Lottie icons, illustrations and loader |
| `loading_animation_widget` | Staggered-dots loading indicator |
| `visibility_detector` | Visibility callbacks for `DSVisibilityDetectorWidget` and Lottie playback |
| `extended_image` | Image caching for `DSNetworkImageWidget` |
| `connectivity_plus` | Reconnect detection for `DSNetworkImageWidget` |
| `carousel_slider` | `DSCarousalWidget` |
| `flutter_staggered_grid_view` | `DSStaggeredGridWidget` |
| `google_maps_flutter` | `DSMapWidget`; each app supplies its own Maps API keys |
| `alchemist` | Golden tests |

`flutter_gen_runner` and `build_runner` (dev dependencies) generate the asset accessors.

## Testing

Run the non-golden tests:

```bash
melos run test --scope=design_system
```

Golden tests use [alchemist](https://pub.dev/packages/alchemist) through
`groupGoldenForBrightnessAndDS` in `test/util/alchemist_utils.dart`, which renders each test case
for every `DesignSystem` value in light and dark. Golden files are stored under each test
folder's `goldens/macos/` and `goldens/ci/`. With `--dart-define=CI=true`,
`test/flutter_test_config.dart` turns off the platform (macOS) golden comparison.

```bash
melos run test_golden --scope=design_system      # compare goldens
melos run test_golden_ci --scope=design_system   # compare with CI=true
melos run update_golden --scope=design_system    # regenerate goldens
```

Or from `layer/design_system`:

```bash
flutter test --tags golden
flutter test --tags golden --update-goldens
```

The test helpers under `test/util/` are not exported.
