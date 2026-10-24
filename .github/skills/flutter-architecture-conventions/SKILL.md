---
description: 'Architecture and code-organization conventions for this Flutter app: use cases, bloc events, feature folder structure, and widget part-file splitting. Use when adding/modifying use cases, blocs, feature folders, or splitting widget files under lib/src/.'
---

# Flutter Architecture Conventions

## Use cases
Every domain use case must extend `BaseUseCase`/`BaseNoParamUseCase` (from the `use_case` package) with a sealed `Failure` hierarchy returning `Either`. Never write a plain class with a bare `call()` method - this loses automatic logging/interceptor support and error-mapping consistency.
A use case that returns a `Stream` always extends `BaseStreamUseCase`/`BaseNoParamStreamUseCase`, which emits an `Either` for every value and turns a stream error into a `Left` instead of ending the stream. Name it `Watch<Subject>UseCase` (for example `WatchLocaleUseCase`, `WatchInternetConnectionUseCase`), never `Get<Subject>StreamUseCase`. Listeners skip a `Left` and keep listening.
Use cases belong to the owning feature's `domain/use_case/`, never the app's `utility/` folder.
Name injected use case fields after their full type in lower camel case, preserving the
`UseCase` suffix and subject (for example `_getLocalAssistantAvailabilityUseCase`, not
`_getLocalAvailability`).

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

@register
class WatchFooUseCase extends BaseNoParamStreamUseCase<Foo, WatchFooFailure> {
  @protected
  @override
  Stream<Foo> execute() => _fooRepository.fooChanges;

  @protected
  @override
  WatchFooFailure mapErrorToFailure(Object e, StackTrace st) => ...;
}

// ❌ Wrong
class GetFooUseCase {
  FutureOr<Foo> call() async { ... }
}

class GetFooStreamUseCase {
  Stream<Foo> call() => _fooRepository.fooChanges;
}
```

### Use cases never throw — they always return a `Failure`
A use case's public result is always an `Either`; callers must never need a `try/catch`.

- Inside `execute`, never `throw` for a domain/business outcome (feature disabled, invalid input,
  a composed use case returning `Left`, empty result, ...). Return `Left(SomeFailure(...))` directly.
  When composing use cases, return `Left(childEither.left)` (propagate the child failure unchanged).
- Exceptions may only originate from infrastructure calls (repositories, data sources, SDKs).
  Do not catch-and-rethrow them or add domain `throw`s; they are converted by
  `mapErrorToFailure`, which is the safety net and must be **total**: every exception type maps to
  a concrete `Failure`, with a catch-all `Unknown` failure as the last case. It never rethrows.
- Never use exceptions as control flow between a use case's own steps just to reach
  `mapErrorToFailure`.

```dart
// ✅ Correct
final isEnabledEither = await _isFeatureEnabledUseCase(flag);
if (isEnabledEither.isLeft) {
  return Left(AiImageUnavailableFailure(cause: isEnabledEither.left));
}
if (!isEnabledEither.right) return const Left(AiImageFeatureDisabledFailure());

// ❌ Wrong
if (isEnabledEither.isLeft) throw AiImageUnavailableException(cause: isEnabledEither.left);
if (!isEnabledEither.right) throw const AiImageFeatureDisabledException();
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

Register events with private `_map<EventName>ToState` methods rather than inline handlers. The
one exception is view tracking: a bloc whose screen tracks views mixes in
`ScreenTrackingBlocMixin` (`lib/src/utility/screen_tracking_bloc_mixin.dart`), overrides
`screenTrackingDelegate`, and registers events whose handlers would only track with
`trackScreenViewOn<ScreenVisibleEvent>()` and
`trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId)`. Events that also load or
change state keep their own `_map...ToState` handler.

## Feature presentation boundaries
Blocs, states, and events are module-internal presentation details; do not export them from
public feature barrels or consume them from other features or app composition. Expose domain
data through feature-owned use cases instead. Public module widgets and routes own their
internal bloc providers. Route builders return screens directly; provider setup belongs inside
the screen, not in the route definition.

Screens build their frame with `ScreenScaffoldWidget<XBloc, XState>`
(`lib/src/widget/screen_scaffold_widget.dart`) instead of nesting `BlocProvider`, `Builder`,
`RouteObserverWidget`, `BlocListener` and `Scaffold` themselves. It provides the bloc from the
service locator. Add the start event in `onCreate` and the visibility event in `onResume`, and
pass one-off effects (snackbars, navigation) as `listenWhen`/`listener`. Retained singleton
sessions use `isRetained: true`, so navigating away does not close the shared session. A screen
shown in a dialog passes `hasScaffold: false`. Widgets passed as `appBar`, `drawer` or
`floatingActionButton` that need the bloc read it in their own build (e.g. a screen's
`AppBarWidget`), because the screen's own context is above the provider. Wrappers that don't need
the bloc, such as `LocalAssistantVisibilityWidget`, go around it.

```dart
return ScreenScaffoldWidget<ExperiencesBloc, ExperiencesState>(
  onCreate: (bloc) => bloc.add(const LoadExperiencesEvent()),
  onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
  body: const ContentWidget(),
);
```

Use `design_system` components whenever an equivalent exists. Render user-facing plain text with
`DSTextWidget`, choosing its style from `context.typography` and color from
`context.colorPalette`; do not use Flutter `Text` as a shortcut. Prefer DS buttons, icons, app-bar
components, and spacers where they fit without changing the screen's behavior or required layout.

## Screen content states and padding
Every screen renders its content with `ScreenContentWidget`
(`lib/src/widget/screen_content_widget.dart`) instead of its own scroll view,
`_LoadingWidget`/`_ErrorWidget` or footer.

- **Loading and error** fill the screen on their own: the lottie `DSLoadingWidget` (the only
  loading style for screen states; `ScreenLoadingContent(message:)` explains a long wait) or a
  translated `DSErrorCardWidget` (`ScreenErrorContent(failure, onRetry:)`, or
  `ScreenErrorContent.message(text)` for errors the feature words itself).
- **Loaded content** is `ScreenLoadedContent.slivers([...], scrollController:)`. The widget builds
  the scroll view and always ends it with the screen footer that the app provides through
  `ScreenFooterProviderWidget`, so screens never place `FooterWidget` themselves and blocs don't
  load the profile for it. Content shorter than the screen is padded to the screen height, so the
  footer always starts below a full screen of content. The page header (such as `PageAppBarWidget`) is one of the slivers.
  Only content that fills the screen and scrolls itself, such as a chat, uses
  `ScreenLoadedContent.fullScreen(child)`, which has no footer.
- **Rebuilds** happen only when the state type changes unless `buildWhen` is given. Pass
  `(previous, current) => previous != current` when a loaded state can follow another loaded state
  with new data, `(_, _) => false` when the sections rebuild themselves, and a `buildWhen` for a
  single state class with a status enum. A screen without loading states always returns loaded
  content.
- **Impressions:** report them as `ViewStateVisibleEvent(content.trackingLabel)` with an
  `impressionPrefix`; omit both on screens without impression tracking.
- A stateful section inside the screen's slivers uses `ScreenContentSliverWidget`, which never
  adds a footer.

```dart
return ScreenContentWidget<ExperiencesBloc, ExperiencesState>(
  impressionPrefix: 'experiences',
  contentOf: (state) => switch (state) {
    LoadingState() => const ScreenLoadingContent(),
    ErrorState(:final failure) => ScreenErrorContent(failure),
    LoadedState(:final experiences) => ScreenLoadedContent.slivers([
      PageAppBarWidget(title: context.localizations.experiencesTitle),
      SliverToBoxAdapter(child: ExperienceListWidget(experiences: experiences)),
    ]),
  },
  onContentVisible: (content) =>
      context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
);
```

Use the design system's `context.screenHorizontalPadding` for a screen's horizontal padding;
don't redeclare the mobile/tablet/desktop switch in a private `BuildContext` extension.

## Presentation extensions
Extensions that need `BuildContext`/localization (e.g. formatting an entity for display) live in `presentation/extension/` with an `_extension.dart` barrel, exported from `presentation/_presentation.dart`. Never put them in the domain layer or in `widget/`. Examples: `experience_date_range_extension.dart`, `project_date_range_extension.dart`, `locale_code_extension.dart`. Screen-specific ones sit next to their screen (`screen/<name>/extension/`).

## Bloc folder shortcut extension
Every feature's `bloc/` folder includes a `bloc_extension.dart` defining a `BuildContext` shortcut, exported from that folder's `_bloc.dart` barrel:

```dart
extension ContextExtension on BuildContext {
  XBloc get bloc => read<XBloc>();

  XState get state => bloc.state;
}
```

Use `context.bloc`/`context.state` in widgets instead of `context.read<XBloc>()`/`context.watch<XBloc>().state`.

## Entities are plain; models carry JSON; mappers bridge them
- **Entities** (`domain/entity/`) only define fields, equality and `toString`. They never contain `fromJson`/`toJson` or any serialization knowledge.
- **Models** (`data/model/`) are the data-layer shape and own JSON support (`@JsonSerializable` with `fromJson`/`toJson`; use `explicitToJson: true` for nested models). Nested values get their own model, e.g. `AiImageAppConfigModel` inside `PortraiAppConfigModel`.
- **Mappers** (`data/mapper/`) transform model ↔ entity. Repositories parse JSON into a model and map it to an entity; caches (`KeyValueCache`/`DBCache`) store models, never entities. A nested model gets its own mapper which the parent mapper receives through its constructor.
- Every entity returned from a repository therefore has a data-layer equivalent. If an entity has no model, or an entity parses JSON itself, that is a violation of this convention (see `app_config`: `PortraiAppConfigEntity` / `PortraiAppConfigModel` / `PortraiAppConfigMapper`).

## Mappers implement `Mapper`/`BiMapper`
Every model↔entity mapper in `data/mapper/` implements `BiMapper<Model, Entity>` (or `Mapper<From, To>` when only one direction exists) from the `core` layer, is `@register`ed and `const` where possible. Use `to`/`from` (or `map`) for the interface methods.

```dart
@register
class LanguageMapper implements BiMapper<LanguageModel, LanguageEntity> { ... }
```

If a direction needs extra input the interface can't carry (e.g. a cache key or a definition), implement `Mapper` for the direction that fits and add a separate method for the other, with a doc comment saying why it isn't a `BiMapper` (see `AiImageMapper`, `AppFeatureFlagMapper`). Classes that transform data without mapping a model to an entity (e.g. `AiImageBackgroundRemover`) are not mappers.

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
