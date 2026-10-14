---
description: Use whenever you add, change, rename or remove anything in layer/design_system (widgets, tokens, themes, assets), to keep its golden tests and the Widgetbook storybook in sync.
---

# Design System Change Conventions

Code of conduct: a change to `layer/design_system` is **not done** until its
golden tests and its storybook use case reflect it. Never leave either for a
follow-up.

## Checklist for every design_system change

1. **Golden test** (`layer/design_system/test/src/**`, mirroring `lib/src/**`)
   - New widget/variant/state: add or extend a test using
     `groupGoldenForBrightnessAndDS` with one `TestCase` per visual variant.
   - Changed look (size, color, layout, new parameter): update the existing
     test cases, then regenerate the PNGs and commit them:
     `melos run update_golden` (or `flutter test --tags golden --update-goldens`
     in `layer/design_system`). Review the diff of every changed PNG.
   - Removed widget: delete its test and its `goldens/` folder.
   - See `golden-test-conventions` for the helper and layout rules.
2. **Storybook** (`app/storybook/lib/src/component/{atom|molecule|organism}/`)
   - New widget: add a `<name>_use_case.dart` with `@UseCase`, knobs for every
     meaningful parameter and the global extensions.
   - Changed widget (new/renamed/removed parameter, new enum value, new
     style): update its use case so the knobs cover it.
   - Removed widget: delete the use case.
   - Regenerate with
     `dart run build_runner build --delete-conflicting-outputs` in
     `app/storybook` so `main.directories.g.dart` is committed with the change.
3. **Barrel + README**: export from the public barrel and update
   `layer/design_system/README.md` when the public API changes.
4. **Assets**: new asset files go in `layer/design_system/assets/` and the
   flutter_gen output is regenerated (`dart run build_runner build` in
   `layer/design_system`).

## Before finishing

- `flutter analyze` and `flutter test` pass in `layer/design_system`
  (goldens included, on macOS) and `app/storybook`.
- Mention in the PR `## Testing` which goldens were regenerated and which
  storybook use cases were added or updated.

## Related skills

- `golden-test-conventions` — how to write the golden tests.
- `flutter-testing-conventions` — general test rules.
- `creating-new-modules` — wiring and barrels.
