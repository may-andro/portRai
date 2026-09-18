---
description: Use when adding or updating a golden test for a design_system widget in this Flutter workspace, to follow the alchemist-based per-theme/brightness golden test pattern instead of ad hoc goldenTest calls.
---

# Golden Test Conventions

Golden tests live only in `layer/design_system/test/src/**` (component and
theme tests), using the `alchemist` package via two shared helpers in
`layer/design_system/test/util/alchemist_utils.dart`.

## Writing a golden test

Use `groupGoldenForBrightnessAndDS` to render a widget across **every**
`DesignSystem` value and both `Brightness.light`/`Brightness.dark` — don't
call `goldenTest`/`groupGolden` directly for a new widget test.

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSIconButtonWidget',
    (theme) => [
      TestCase(
        'small',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
          onPressed: () {},
        ),
      ),
      // one TestCase per visual variant: sizes, states, disabled, etc.
    ],
  );
}
```

- The `(theme) => [...]` callback receives the current `DSTheme` for the
  design system/brightness combination being rendered — always source
  colors from `theme.colorPalette`, never hardcode a `Color`.
- Add one `TestCase(description, widget)` per meaningful visual
  variant/state (sizes, enabled/disabled, selected/unselected) rather than
  one enormous test case.
- Use `groupGolden` (single design system/brightness, no cross-product)
  only when a test is inherently tied to one theme (rare — prefer the
  `ForBrightnessAndDS` variant by default).

## File/folder layout

Test file path mirrors the widget's `lib/src/...` path under
`test/src/...` (e.g.
`lib/src/component/atom/button/ds_icon_button_widget.dart` →
`test/src/component/atom/button/ds_icon_button_widget_test.dart`), per
`flutter-testing-conventions`. Golden PNGs are written to a sibling
`goldens/<platform>/` folder and are checked into git — never manually
edit or hand-craft a golden PNG.

## CI behavior

`test/flutter_test_config.dart` disables `PlatformGoldensConfig` when the
`CI` Dart define is set, so golden **comparisons** only run locally
(typically on macOS, matching the `runs-on: macos-latest` requirement
called out in `ci-workflow-conventions` for this package) — CI still runs
the tests but skips platform-specific pixel comparison. Regenerate goldens
locally with alchemist's update mode after an intentional visual change,
then commit the updated PNGs alongside the code change; don't regenerate
speculatively.

## Don't invent

Don't add a bespoke `goldenTest(...)` call bypassing `alchemist_utils.dart`
for a `design_system` widget — the shared helpers guarantee every widget is
checked against all design systems and both brightnesses consistently.
Golden tests belong to `design_system` only; don't add golden testing to
app feature widgets without discussing it first, since the app currently
has none.

## Related skills

- `flutter-testing-conventions` — general test naming/mocking rules that
  still apply to non-golden tests in this package.
- `ci-workflow-conventions` — why `design_system`'s workflow runs on
  `macos-latest`.
