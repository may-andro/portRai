# GitHub Copilot Instructions

This repo's detailed conventions live in per-topic skills under `.github/skills/`, which are
loaded automatically when relevant. Treat the summary below as always-on ground rules; consult
the linked skill for full detail (code examples, rationale, edge cases) before acting in that
area.

## General Coding Behavior
- State assumptions; if the request is ambiguous or has multiple interpretations, ask before coding.
- Write the minimum code that fully solves the task: no unrequested features, options, or single-use abstractions.
- Reuse existing helpers, components, and installed dependencies before writing new code; never add a dependency for a few lines.
- Make surgical changes: every changed line traces to the request; match existing style; don't refactor or delete unrelated code (mention it instead).
- Remove only imports/members your change made unused.
- Never cut validation, error handling, security, accessibility, or the tests/callers your change affects (repo conventions below still apply).
- Define a verifiable success check (test, analyze) and run it before finishing.
- End with one or two lines: what was skipped or not verified, and any risk.

## Architecture Conventions
See [`.github/skills/flutter-architecture-conventions/SKILL.md`](skills/flutter-architecture-conventions/SKILL.md).

- Use cases extend `BaseUseCase`/`BaseNoParamUseCase` with a sealed `Failure` hierarchy and `Either` — never a plain class with a bare `call()`.
- Don't manually log use case success/failure — `LogUseCaseInterceptor` already does it.
- Widgets dispatch bloc events, never call `appServiceLocator` use cases directly.
- Bloc UI events are named `<Action>ClickEvent`.
- Every `bloc/` folder has a `bloc_extension.dart` with `context.bloc`/`context.state`.
- Data mappers implement `BiMapper`/`Mapper` from `core`; if extra input prevents it, document why in the class doc.
- Features follow `lib/src/feature/<feature>/{data,domain,presentation}`, with screens under `presentation/screen/<screen_name>/`.
- Content-only sub-widgets are split into `part` files, unprefixed with the feature name.

## Testing Conventions
See [`.github/skills/flutter-testing-conventions/SKILL.md`](skills/flutter-testing-conventions/SKILL.md).

- Test names follow `should ... when ...`.
- Mocks live one-per-file under `test/mock/`, mirroring `lib/src/`, with stubbing helpers as extensions.
- Widget tests needing localizations/design-system context use `TestWidgetWrapper`.
- Never construct a `Bloc` inside `setUp()` in widget tests — build it inside each `testWidgets` body.

## Branch & PR Conventions
See [`.github/skills/pr-and-branch-conventions/SKILL.md`](skills/pr-and-branch-conventions/SKILL.md).

- Branch off `develop`; name branches `<type>/<kebab-case>` (`app/`, `feature/`, `fix/`, `chore/`, `docs/`).
- PR titles use Conventional Commits: `<type>(<optional-scope>): <description>`, e.g. `feat(app): add portfolio dashboard`.
- PR descriptions use `## Summary` / `## Changes` / `## Testing` / `## Validation`, not the checkbox template, unless asked otherwise.

## Creating New Modules
See [`.github/skills/creating-new-modules/SKILL.md`](skills/creating-new-modules/SKILL.md).

- New shared, reusable concerns → `layer/<name>` package (own `pubspec.yaml`, added to root workspace).
- New product functionality → app feature under `app/portrai/lib/src/feature/<name>` (not a separate package).
- Both wire a `ModuleConfigurator` (often via `@generateConfigurator`) into `module_configurators.dart`; screens register routes via a `ModuleRoute`.

## README Conventions
See [`.github/skills/readme-conventions/SKILL.md`](skills/readme-conventions/SKILL.md).

- Plain headings, no emoji, single Title Case H1; describe behavior factually, with no history or circumstantial details.
- Layer READMEs: `Features → Getting Started → Usage → API Reference/Key Concepts → Platform Support → Dependencies → Testing`.
- App READMEs: `Features → Getting Started → Architecture → Development → Configuration → Deployment → Contributing`, linking to the root README instead of duplicating it.

## Import Boundaries
See [`.github/skills/import-boundary-conventions/SKILL.md`](skills/import-boundary-conventions/SKILL.md).

- Never import another package's `lib/src/**` — only its public top-level barrel.
- Never import another app feature's private underscore-prefixed barrel files (`_bloc.dart`, etc.) — only its public feature barrel.
- Enforced by the `portrai_analyzer` plugin rules, wired into root `analysis_options.yaml` via `plugins:`; CI runs `dart analyze --fatal-infos .`, so a violation fails the check.

## CI Workflows
See [`.github/skills/ci-workflow-conventions/SKILL.md`](skills/ci-workflow-conventions/SKILL.md).

- One `.github/workflows/<name>.yaml` per layer/app, triggered on PRs touching that path, using the shared `setup-flutter-module` + `flutter-quality-checks` composite actions (`setup-dart-module` + `dart-quality-checks` for Dart tools).
- Release pipelines are tag-triggered and chain `extract-version → quality → build-<platform> → deploy-<platform>` via reusable `_build_*`/`_deploy_*` workflows.

## Dependency Injection Annotations
See [`.github/skills/module-injector-annotation-conventions/SKILL.md`](skills/module-injector-annotation-conventions/SKILL.md).

- `@register`/`@registerSingleton` for factory/singleton registration; `@Register(as:)`/`@RegisterSingleton(as:)` to bind a concrete class to an abstract type.
- `@Inject(ConcreteType)` on a constructor param resolves a specific concrete type instead of the abstract default — required for repository delegation chains.
- `@generateConfigurator` on a `SimpleModuleConfigurator` subclass generates `$register<Module>Dependencies` from every `@register`/`@registerSingleton` class in that directory.

## Feature Flags
See [`.github/skills/feature-flag-conventions/SKILL.md`](skills/feature-flag-conventions/SKILL.md).

- Each feature declares its own `<Feature>FeatureFlags` holder of `AppFeatureFlagDefinition`s (key `feature_<name>`, plus `displayName`/`description`).
- Register them with `AppFeatureFlagDefinitionRegistry` from the feature's `postDependenciesSetup`, not by calling the layer's `FeatureFlagController` directly.

## Tracking Events
See [`.github/skills/tracking-event-conventions/SKILL.md`](skills/tracking-event-conventions/SKILL.md).

- Each screen owns one `@register`ed `<Screen>TrackingDelegate extends ScreenTrackingDelegate`, injected into its bloc.
- Widgets/blocs never call `TrackingReporter` directly — only through the screen's delegate methods.

## Error & Exception Handling
See [`.github/skills/error-handling-conventions/SKILL.md`](skills/error-handling-conventions/SKILL.md).

- Domain failures extend `BasicFailure`; annotate user-facing ones with `@Localizable('<arbKey>')` and render via the generated `FailureTranslator.translate`.
- `error_reporter`'s `BlacklistErrorHandler`/`FatalErrorHandler` are for reported/global errors, not domain `Failure`s.

## Design System Changes
See [`.github/skills/design-system-change-conventions/SKILL.md`](skills/design-system-change-conventions/SKILL.md).

- Any change in `layer/design_system` must update its golden tests (regenerate and commit PNGs) and its Widgetbook use case in `app/storybook` (regenerate `main.directories.g.dart`) in the same change.

## Golden Tests
See [`.github/skills/golden-test-conventions/SKILL.md`](skills/golden-test-conventions/SKILL.md).

- `design_system` widget tests use `groupGoldenForBrightnessAndDS` from `test/util/alchemist_utils.dart`, covering every design system × brightness.
- CI runs them with `--dart-define=CI=true`, which compares against `goldens/ci/` and skips only the `goldens/macos/` comparison; don't add golden tests to app features.

## Localization
See [`.github/skills/localization-conventions/SKILL.md`](skills/localization-conventions/SKILL.md).

- User-facing strings go in ARB files (`app/portrai/lib/l10n/arb/app_{en,es,nl}.arb`) with a `@key` description block, accessed via `context.localizations`.
- Never hand-edit generated `app_localizations*.dart`/`FailureTranslator` files.

## Release & Versioning
See [`.github/skills/release-versioning-conventions/SKILL.md`](skills/release-versioning-conventions/SKILL.md).

- Releases are triggered by pushing a `<version>+<build>-<suffix>` tag (`-review`, `-prod`, `-review-storybook`, `-prod-storybook`) or `legal-<version>`.
- The tag's version matches the `pubspec.yaml` `version:`; the build number comes from the tag. For Portrai, `melos run prepare_portrai_release` proposes the next tag.

## Naming
See [`.github/skills/naming-conventions/SKILL.md`](skills/naming-conventions/SKILL.md).

- Never use single-letter or abbreviated names (`w`, `h`, `c`, `l`, `i`, `idx`) for variables, parameters or lambda arguments — use full, meaningful names that say what they hold or do.

## Adding new conventions
When you notice a repeated pattern or correction, add it to the relevant skill file (or create a
new skill under `.github/skills/<topic>/SKILL.md`) and add a one-line summary + link here, rather
than growing this file into a monolith.
