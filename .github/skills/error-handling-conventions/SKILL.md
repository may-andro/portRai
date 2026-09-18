---
description: Use when defining domain failures for a use case, raising/reporting exceptions, or wiring blacklist/fatal error handling in this Flutter workspace, to keep the Failure and AppException hierarchies consistent.
---

# Error & Exception Handling Conventions

Two distinct hierarchies exist and are not interchangeable — know which one
applies.

## `Failure` (domain layer, from `use_case`)

Every use case returns `Either<XFailure, T>` where `XFailure` is a sealed
hierarchy rooted in `BasicFailure` (see `flutter-architecture-conventions`
for the full use-case pattern). `BasicFailure` (`layer/use_case/lib/src/model/failure.dart`)
carries an optional `cause` and auto-implements `toString()`/`Equatable`
props — don't override `toString()` or `props` yourself.

```dart
sealed class GetAppStoreUrlFailure extends BasicFailure {
  const GetAppStoreUrlFailure({super.cause});
}

@Localizable('errorForceUpdateStoreUrl')
class GetAppStoreUrlUnknownFailure extends GetAppStoreUrlFailure {
  const GetAppStoreUrlUnknownFailure({super.cause});
}
```

`Failure`s are what blocs put into state and what the UI renders — they are
**not** reported to crash/error reporting on their own.

### `@Localizable('<arbKey>')`

Annotate any concrete `Failure` subclass that should show a user-facing
message with `@Localizable('<arbKey>')` (from `use_case`'s annotation, see
`layer/use_case/lib/src/annotation/localizable.dart`). A build_runner
generator collects every annotated failure into
`app/portrai/lib/generated/failure_translator.g.dart`'s
`FailureTranslator.translate(context, failure)`, a `switch` mapping each
failure type to `context.localizations.<arbKey>`. Call
`FailureTranslator.translate(context, state.failure)` in the widget instead
of hand-writing per-failure message strings. The ARB key referenced must
exist in every locale ARB file (see `localization-conventions`) or
`gen-l10n` fails.

## `AppException`/reported errors (from `error_reporter`)

`ErrorReporter` deals with things that get sent to a backend (Firebase
Crashlytics, etc.), independent of `Failure`/use cases. Two extension
points, both implemented once at the app level in
`app/portrai/lib/src/error_reporter/`:

- `BlacklistErrorHandler` — filters errors that should **not** be reported.
  This app's `AppBlacklistErrorHandler` blacklists a custom
  `BlacklistException` marker type — throw/wrap in `BlacklistException` for
  errors you intentionally want swallowed rather than reported (e.g.
  expected cancellations).
- `FatalErrorHandler` — reacts to unrecoverable errors. This app's
  `AppFatalErrorHandler.onFatalError` calls `exit(1)` — there is no crash
  dialog/recovery flow, so treat "fatal" as genuinely unrecoverable, not a
  hook for regular error UI.

Register custom handlers via `BlacklistErrorController`/`FatalErrorController`
from the app's error-reporter module configurator
(`app/portrai/lib/src/module_configurator/app_module_configurator.dart`), not
ad hoc at call sites.

## Don't invent

- Don't create a new exception hierarchy parallel to `Failure`/
  `BasicFailure` for domain errors — every use case failure extends
  `BasicFailure`.
- Don't call `ErrorReporter`/`FatalErrorController` directly from a bloc to
  report a `Failure` — logging/reporting of use case failures is already
  handled by the `LogUseCaseInterceptor` (see `flutter-architecture-conventions`);
  only reach for `error_reporter` primitives for errors outside the use-case
  flow (global Flutter errors, uncaught async errors).

## Related skills

- `flutter-architecture-conventions` — use case/bloc structure that
  produces `Failure`s.
- `localization-conventions` — where `@Localizable` ARB keys must be added.
