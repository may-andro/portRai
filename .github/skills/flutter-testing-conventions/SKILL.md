---
description: 'Conventions for writing Dart/Flutter unit and widget tests in this repo. Use when writing, reviewing, or fixing tests, mocks, or fakes under test/.'
---

# Flutter Testing Conventions

## Test naming
All test names **must** follow the `should ... when ...` pattern:

```dart
// ✅ Correct
test('should log debug message when onChange is called', () { ... });
test('should call onError when use case throws', () { ... });

// ❌ Wrong
test('logs debug message', () { ... });
test('onChange delegates to logReporter', () { ... });
```

## Shared mocks
Each mock class lives in its own file under `test/mock/`, named `mock_<class>.dart`. Never define local `_MockX` classes inside individual test files.

Mirror the `lib/src/` folder structure inside `test/mock/` so the folder doesn't become a huge flat dump as the app grows:

```
lib/src/feature/force_update/domain/use_case/get_app_store_url_use_case.dart
test/mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart

lib/src/feature/force_update/domain/repository/app_version_repository.dart
test/mock/feature/force_update/domain/repository/mock_app_version_repository.dart

lib/src/utility/log_use_case_interceptor.dart (consumer)
test/mock/utility/mock_log_reporter.dart
```

`test/src/feature/<feature>/...` and `test/mock/feature/<feature>/...` must mirror the exact `lib/src/` path of the feature under test, including any `screen/<screen_name>/` segment (see the architecture conventions skill for feature folder structure).

Import only the mock files you need:
```dart
import '../../../../../mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart';
```

Co-locate reusable stubbing helpers with the mock, as an extension on it, so every test stubs the same way instead of repeating raw `when(...)` calls:

```dart
class MockGetAppStoreUrlUseCase extends Mock implements GetAppStoreUrlUseCase {}

extension MockGetAppStoreUrlUseCaseStub on MockGetAppStoreUrlUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetAppStoreUrlFailure, Uri> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
```

`Fake` classes needed only to `registerFallbackValue` for `any()` matching also belong in `test/mock/` (e.g. `fake_open_external_url_param.dart`), not inline in the test file.

## Widget tests: shared wrapper
Use `test/util/test_wrapper_widget.dart`'s `TestWidgetWrapper` to pump any widget that relies on `context.localizations` or the design system's `context.colorPalette`/`context.typography`. It wraps the child in a `MaterialApp` with the app's localization delegates plus `DSThemeBuilderWidget`:

```dart
await tester.pumpWidget(
  TestWidgetWrapper(
    child: BlocProvider.value(value: bloc, child: const MyWidget()),
  ),
);
```

## Widget tests: never build a `Bloc` inside `setUp()`
Construct the `Bloc` (and its mocked use cases) **inside each `testWidgets` body**, not in `setUp()`. `setUp()` runs outside the `FakeAsync` zone that wraps an individual `testWidgets` body; a `Bloc` built in `setUp()` captures the wrong zone at construction, so its internal event processing never synchronizes with the test's pumped clock. Symptom: `pumpAndSettle()` returns without the bloc's `on<Event>` handler ever resuming past its first `await`, so mocked use cases appear to never be called even though the tap/event was dispatched.

```dart
// ✅ Correct - bloc created per test
testWidgets('should open the store when tapped', (tester) async {
  final getAppStoreUrlUseCase = MockGetAppStoreUrlUseCase();
  final bloc = ForceUpdateBloc(getAppStoreUrlUseCase: getAppStoreUrlUseCase, ...);
  addTearDown(bloc.close);
  ...
});

// ❌ Wrong - bloc created in setUp(), tap silently never completes the handler
setUp(() {
  bloc = ForceUpdateBloc(...);
});
```

If several tests in a `group` need the same bloc, factor construction into a local helper function called from inside each `testWidgets` body - not a `setUp()` callback.
