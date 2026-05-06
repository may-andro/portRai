# Design System

A scalable, multi-theme design system for Flutter — built on **atomic design** (atoms → molecules → organisms), fully golden-tested across all 12 built-in themes in both light and dark mode.

---

## Architecture

The design system is structured around **atomic design**:

```
lib/src/component/
├── atom/          # Indivisible building blocks (Button, Text, Icon, Card …)
├── molecule/      # Composed atoms forming a focused pattern (TabItem, Tag, SnackBar …)
└── organism/      # Full sections assembled from molecules (Dialog, ErrorCard, Carousel …)
```

Each layer exports a single barrel file (`atom.dart`, `molecule.dart`, `organism.dart`).  
The top-level `design_system.dart` re-exports everything.

```dart
import 'package:design_system/design_system.dart';
```

---

## Components

### Atoms

| Widget | Description |
|--------|-------------|
| `DSButtonWidget` | Primary, secondary, error, text variants · 4 sizes · icon support · loading/disabled |
| `DSIconButtonWidget` | Icon-only button with 3 sizes and elevation support |
| `DSTextWidget` | Themed text with full typography scale, italic, decoration, truncation |
| `DSIconWidget` | Themed icon with `small / medium / large` sizes |
| `DSCardWidget` | Rounded, elevated card with optional tap, custom radius, opacity |
| `DSHorizontalDividerWidget` | Horizontal rule with configurable thickness and colour |
| `DSVerticalDividerWidget` | Vertical rule with configurable thickness and colour |
| `DSLoadingWidget` | Animated staggered-dots loading indicator |
| `DSResponsiveContainerWidget` | Builder that switches on `mobile / tablet / desktop` |
| `DSVisibilityDetectorWidget` | Fires a callback when the widget enters/leaves the viewport |

### Molecules

| Widget | Description |
|--------|-------------|
| `DSAppBarWidget` | Branded app bar with optional back button and action slots |
| `DSDetailSectionWidget` | Titled section header above arbitrary child content |
| `DSExpandableCardWidget` | Animated collapsible card with chevron header |
| `DSGradientBlobWidget` | Pulsating radial-gradient decorative blob |
| `DSHoverableContainerWidget` | `MouseRegion` builder exposing hover state |
| `DSInfoChipWidget` | Icon + label pill using secondary container colours |
| `DSLabeledInfoRowWidget` | Icon-in-circle, label/value row, optional tappable chevron |
| `DSPositionIndicatorWidget` | Scrollable dot-row position indicator |
| `DSQuoteTextWidget` | `❝` glyph + capped body text for blockquotes |
| `DSSnackBar` | Data class → `SnackBar`; success / error / info colour variants |
| `DSTabItemWidget` | Animated navigation tab with selected/hover underline |
| `DSTagWidget` | Rounded skill/category badge in primary-container colours |
| `DSTextFieldWidget` | Full-featured text field; normal / password types, validation states |
| `DSTitleDescriptionWidget` | Fixed-height title + description pair for grids and cards |
| `DSNetworkImageWidget` | Cached network image with auto-retry on reconnect |

### Organisms

| Widget | Description |
|--------|-------------|
| `DSBulletPointListWidget` | Vertically stacked bullet-point list |
| `DSCarousalWidget` | Carousel slider wrapping `carousel_slider` |
| `DSDialogWidget` | Themed, rounded modal dialog with responsive sizing |
| `DSErrorCardWidget` | Error state card with icon, message, and optional retry button |
| `DSSectionContainerWidget` | Visibility-triggered section with animated title, background theming, and responsive padding |
| `DSStaggeredGridWidget` | Masonry grid layout via `flutter_staggered_grid_view` |

---

## Theming

The design system ships **12 built-in themes**, each with its own colour palette, typography, and spacing:

| Theme | Inspiration |
|-------|-------------|
| `beltane` | Celtic spring festival |
| `carnival` | Brazilian carnival |
| `chuseok` | Korean harvest festival |
| `diwali` | Hindu festival of lights |
| `halloween` | Gothic Halloween |
| `hogeras` | Mediterranean coastal |
| `hogmanay` | Scottish New Year |
| `holi` | Indian festival of colours |
| `obon` | Japanese lantern festival |
| `pachamama` | Andean earth festival |
| `sakura` | Japanese cherry blossom |
| `xmas` | Christmas |

Each theme is available in **light and dark** brightness.

### Applying a theme

```dart
DSThemeBuilderWidget(
  brightness: Brightness.light,
  designSystem: DesignSystem.sakura,
  child: MyWidget(),
)
```

### Reading theme values from `BuildContext`

```dart
// Colour
context.colorPalette.brand.primary.color

// Typography
context.typography.titleLarge

// Spacing (responsive — grows on tablet/desktop)
context.space(factor: 2)

// Responsive breakpoint
context.deviceResolution   // mobile | tablet | desktop
context.isDesktop
```

### Responsive `screenHorizontalPadding`

```dart
// Returns EdgeInsets adjusted for the current breakpoint
context.screenHorizontalPadding
```

---

## Foundation

```
lib/src/foundation/
├── color/        # DSColor, DSColorPalette
├── dimen/        # DSRadius, DSElevation, DSGrid, DSDimen
└── typography/   # DSTextStyle, DSTypography
```

Access via `context.colorPalette`, `context.dimen`, `context.typography`.

---

## Assets

```dart
DSImage.logo()          // branded logo widget
DSImage.logoPath        // asset path (for Image.asset)
```

---

## Testing

Golden tests use **[alchemist](https://pub.dev/packages/alchemist)** and cover every component across all 12 themes × 2 brightnesses × 2 variants (macOS + CI).

```
test/src/component/
├── atom/
│   ├── button/    ds_button_widget_test.dart
│   │              ds_icon_button_widget_test.dart
│   ├── container/ ds_card_widget_test.dart
│   ├── divider/   ds_horizontal_divider_widget_test.dart
│   │              ds_vertical_divider_widget_test.dart
│   ├── icon/      ds_icon_widget_test.dart
│   ├── loading/   ds_loading_widget_test.dart
│   └── text/      ds_text_widget_test.dart
├── molecule/
│   ├── ds_app_bar_widget_test.dart
│   ├── ds_detail_section_widget_test.dart
│   ├── ds_expandable_card_widget_test.dart
│   ├── ds_gradient_blob_widget_test.dart
│   ├── ds_info_chip_widget_test.dart
│   ├── ds_labeled_info_row_widget_test.dart
│   ├── ds_position_indicator_widget_test.dart
│   ├── ds_quote_text_widget_test.dart
│   ├── ds_snack_bar_widget_test.dart
│   ├── ds_tab_item_widget_test.dart
│   ├── ds_tag_widget_test.dart
│   ├── ds_text_field_widget_test.dart
│   └── ds_title_description_widget_test.dart
└── organism/
    ├── ds_bullet_point_list_widget_test.dart
    ├── ds_carousal_widget_test.dart
    ├── ds_dialog_widget_test.dart
    ├── ds_error_card_widget_test.dart
    └── ds_staggered_grid_widget_test.dart
```

**Update golden baselines:**

```bash
# From workspace root (via melos)
melos update_golden

# Or directly
cd layer/design_system
flutter test --update-goldens
```

**Run golden comparison (CI mode):**

```bash
flutter test --dart-define=CI=true
```

> **Not covered by goldens:** `DSNetworkImageWidget` (requires `connectivity_plus` native plugin) and `DSSectionContainerWidget` (async `VisibilityDetector` timers incompatible with `pumpAndSettle`).

---

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅ |
| iOS      | ✅ |
| Web      | ✅ |
| macOS    | ✅ |

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `core` | Workspace utilities |
| `flutter_animate` | Animation primitives |
| `carousel_slider` | Carousel organism |
| `extended_image` | Cached network images |
| `flutter_staggered_grid_view` | Masonry grid organism |
| `loading_animation_widget` | Loading dots atom |
| `visibility_detector` | Viewport visibility callbacks |
| `adaptive_breakpoints` | Responsive breakpoint detection |
