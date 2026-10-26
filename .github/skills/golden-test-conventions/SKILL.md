---
description: Use when adding or updating a golden test for a design_system widget in this Flutter workspace, to follow the alchemist-based per-theme/brightness golden test pattern instead of ad hoc goldenTest calls.
---

# Golden Test Conventions

Golden tests live only in `layer/design_system/test/src/**` (the component
tests under `test/src/component/`), using the `alchemist` package via two
shared helpers in `layer/design_system/test/util/alchemist_utils.dart`.
`alchemist`'s `goldenTest` tags every test `golden`, so the melos scripts
select them with `--tags golden`.

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

- The `(theme) => [...]` callback receives the `DSTheme` for the
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
`flutter-testing-conventions`. Golden PNGs are written to sibling
`goldens/macos/` (platform goldens) and `goldens/ci/` (alchemist's CI
goldens, with text rendered as blocks) folders, shared by every test file in
that directory, and are checked into git — never manually edit or
hand-craft a golden PNG.

## CI behavior

`test/flutter_test_config.dart` disables `PlatformGoldensConfig` when the
`CI` Dart define is set, so the `goldens/macos/` **comparisons** only run
locally (on macOS). CI (`.github/workflows/design_system.yaml`, on
`runs-on: macos-latest` as called out in `ci-workflow-conventions`) runs
`flutter test --dart-define=CI=true`, which still compares against the
`goldens/ci/` images. `melos run test_golden` runs the golden tests locally
and `melos run test_golden_ci` runs them with the CI define; `melos run test`
excludes the `golden` tag. Regenerate goldens locally with
`melos run update_golden` (`flutter test --tags golden --update-goldens`)
after an intentional visual change, then commit the updated PNGs alongside
the code change; don't regenerate speculatively.

## Don't invent

Don't add a bespoke `goldenTest(...)` call bypassing `alchemist_utils.dart`
for a `design_system` widget — the shared helpers guarantee every widget is
checked against all design systems and both brightnesses consistently.
Golden tests belong to `design_system` only; don't add golden testing to
app feature widgets without discussing it first, since the app has none
(`app/portrai` doesn't depend on `alchemist`).

## Related skills

- `design-system-change-conventions` — golden + storybook must be updated on every design_system change.
- `flutter-testing-conventions` — general test naming/mocking rules that
  still apply to non-golden tests in this package.
- `ci-workflow-conventions` — why `design_system`'s workflow runs on
  `macos-latest`.
