---
description: 'Architecture and code-organization conventions for this Flutter app: use cases, bloc events, feature folder structure, and widget part-file splitting. Use when adding/modifying use cases, blocs, feature folders, or splitting widget files under lib/src/.'
---

# Flutter Architecture Conventions

## Use cases
Every domain use case must extend `BaseUseCase`/`BaseNoParamUseCase` (from the `use_case` package) with a sealed `Failure` hierarchy returning `Either`. Never write a plain class with a bare `call()` method - this loses automatic logging/interceptor support and error-mapping consistency.

```dart
// ✅ Correct
sealed class GetFooFailure extends BasicFailure {
  const GetFooFailure({super.cause});
}

@register
class GetFooUseCase extends BaseNoParamUseCase<Foo, GetFooFailure> {
  @protected
  @override
  FutureOr<Either<GetFooFailure, Foo>> execute() async { ... }

  @protected
  @override
  GetFooFailure mapErrorToFailure(Object e, StackTrace st) => ...;
}

// ❌ Wrong
class GetFooUseCase {
  FutureOr<Foo> call() async { ... }
}
```

## Don't duplicate logging
The globally registered `LogUseCaseInterceptor` already logs every use case's params, success, and error automatically. Don't add manual `LogReporter.error`/`.debug` calls in blocs or presentation code just to report a use case failure/success - it's already logged.

## Widgets dispatch bloc events, not service locator calls
Presentation widgets must not resolve use cases from `appServiceLocator` directly to perform actions (e.g. button clicks). Dispatch a bloc event instead and let the bloc own and call the use case(s).

```dart
// ✅ Correct
onPressed: () => context.bloc.add(const UpdateNowClickEvent()),

// ❌ Wrong
onPressed: () async {
  final result = await appServiceLocator.get<SomeUseCase>()();
  ...
},
```

## Bloc event naming
UI interaction events are named `<Action>ClickEvent` (e.g. `HeaderTabClickEvent`, `DrawerClickEvent`), not `<Action>PressedEvent` or other variants.

## Bloc folder shortcut extension
Every feature's `bloc/` folder includes a `bloc_extension.dart` defining a `BuildContext` shortcut, exported from that folder's `_bloc.dart` barrel:

```dart
extension ContextExtension on BuildContext {
  XBloc get bloc => read<XBloc>();

  XState get state => bloc.state;
}
```

Use `context.bloc`/`context.state` in widgets instead of `context.read<XBloc>()`/`context.watch<XBloc>().state`.

## Feature folder structure
Each feature under `lib/src/feature/<feature>/` follows `data/`, `domain/`, `presentation/`. Inside `presentation/`, screens are nested under `screen/<screen_name>/`, not directly under `presentation/`:

```
presentation/
  _presentation.dart          // exports 'route/_route.dart' + 'screen/_screen.dart'
  route/
    _route.dart
    <feature>_module_route.dart
  screen/
    _screen.dart               // exports '<screen_name>/_<screen_name>.dart' for each screen
    <screen_name>/
      _<screen_name>.dart      // exports bloc/_bloc.dart (or bloc file), <screen_name>_screen.dart, tracking/_tracking.dart
      <screen_name>_screen.dart
      bloc/
      tracking/
      widget/
```

Only skip the `screen/` nesting for features with no real screen (e.g. a bottom sheet or other non-screen widget, like `force_update`). A feature with a `*_screen.dart`/`Screen` widget must use `screen/<screen_name>/`.

`test/src/feature/<feature>/...` and `test/mock/feature/<feature>/...` must mirror this exact `lib/src/` path, including the `screen/<screen_name>/` segment (see the testing conventions skill).

## Widget file splitting with `part`
When a screen's `content_widget.dart` has sub-widgets used *only* by that content tree (not shared/exported elsewhere), split them into `part` files rather than separate imported libraries:

```dart
// content_widget.dart
part 'section_widget.dart';
part 'desktop_content_widget.dart';

class ContentWidget extends StatelessWidget { ... }
```

```dart
// section_widget.dart
part of 'content_widget.dart';

class _SectionWidget extends StatelessWidget { ... }
```

Classes and file names in these `part` files must **not** be prefixed with the feature/module name (e.g. `_SectionWidget`, not `_ProfileSectionWidget`) - the prefix is reserved for public, externally-referenced classes. Widgets used outside the content tree (e.g. a screen's header widget) stay as normal separate files, not `part`s.
