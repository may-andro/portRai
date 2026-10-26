# Tracking

Analytics event reporting for Flutter modules. Screens describe events as
`Tracking` objects and send them through a `TrackingReporter`, which forwards
them to Firebase Analytics and, optionally, keeps them in memory for inspection.

## Features

- `Tracking` event model with an area, a name and an optional action, flattened
  into string parameters for the analytics backend
- Predefined events for screen views, view impressions, clicks, app start and
  app initialization
- `ScreenTrackingDelegate` base class that groups the tracking of one screen
  under a `TrackingArea`
- `TrackingImpressionDetectorWidget` that reports a view impression once per ID
  when the child becomes at least 10% visible
- `TrackingModuleConfigurator` that registers a single `TrackingReporter` and
  sends an app start event once all modules are set up

## Getting Started

### Installation

The package is a member of the workspace. Add it to a module's `pubspec.yaml`:

```yaml
dependencies:
  tracking: any
```

```dart
import 'package:tracking/tracking.dart';
```

### Module Configuration

Add `TrackingModuleConfigurator` to the list passed to
`ModuleInjectorController.setUpDIGraph`. Its `registerDependencies` resolves
`FbAnalyticsController`, so the firebase layer's `FirebaseModuleConfigurator`
must come before it in the list.

```dart
final configurators = <ModuleConfigurator>[
  FirebaseModuleConfigurator(/* ... */),
  TrackingModuleConfigurator(isFirebaseEnabled),
  // other modules
];
```

| Parameter | Default | Effect |
|-----------|---------|--------|
| `isFirebaseEnabled` (positional) | required | When `true`, events are sent to Firebase Analytics through `FbAnalyticsController.sendLogEvent`. |
| `keepsSentEvents` | `kDebugMode` | When `true`, the last 200 events are kept in memory and exposed by `TrackingReporter.sentTrackingEvents`. |

The configurator registers `TrackingReporter` as a singleton and, in
`postDependenciesSetup`, sends an `AppStartTracking` event.

## Usage

### Screen tracking delegate

Subclass `ScreenTrackingDelegate` once per screen, with a `TrackingArea` that
names the screen. Expose one method per trackable action.

```dart
import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('example_screen');
}

@register
class ExampleTrackingDelegate extends ScreenTrackingDelegate {
  ExampleTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackItemClick(String itemId) {
    trackEvent(Tracking(name: 'item', action: ClickAction(label: itemId)));
  }
}
```

`ScreenTrackingDelegate` provides:

- `trackScreenView()` sends a `ScreenViewTracking` for the delegate's area and
  makes that area the current one.
- `trackViewEvent(label)` sends a `ViewTracking` with the given label.
- `trackEvent(tracking)` sends any `Tracking`.

### View impressions

Wrap a widget in `TrackingImpressionDetectorWidget` to call `onImpression` the
first time at least 10% of it is visible. Each `impressionId` fires once until
the current area changes.

```dart
TrackingImpressionDetectorWidget(
  impressionId: 'items_section',
  onImpression: () => delegate.trackViewEvent('items_section'),
  child: const ItemsSection(),
)
```

### Inspecting sent events

When `keepsSentEvents` is `true`, `sentTrackingEvents` returns an unmodifiable
map of send time to event, oldest first. It returns `null` otherwise.

```dart
final events = ModuleInjectorController().serviceLocator
    .get<TrackingReporter>()
    .sentTrackingEvents;
```

## API Reference

### TrackingReporter

```dart
abstract interface class TrackingReporter {
  void sendTrackingEvent(Tracking tracking);

  Map<DateTime, Tracking>? get sentTrackingEvents;
}
```

The registered implementation sends each event to every enabled backend:
Firebase Analytics (event name `tracking.name`, parameters
`tracking.parameters`) and the in-memory store.

### Tracking

```dart
Tracking({required String name, required TrackingAction? action})
```

`area` is read from the current tracking area when the event is created.
`parameters` contains `event` (the name), `area`, `action` (the action type,
when present) and the action's own fields, with every value converted to a
string.

| Class | `name` | Action |
|-------|--------|--------|
| `ScreenViewTracking({required TrackingArea area})` | `screen_view` | none; sets the current area to `area` |
| `ViewTracking({required String label})` | `view_impression` | `ViewAction` |
| `ClickTracking({required String label, String? value})` | `click` | `ClickAction` |
| `AppStartTracking()` | `app_started` | `SetupAction('uninitialised')`; sets the current area to `SplashArea` |
| `AppInitializationFinishedTracking({bool isSuccessful = true})` | `app_initialization` | `SetupAction('Initialized')` or `SetupAction('Initialization Failed')` |

### TrackingAction

Abstract base with an `action` type string and a `toJson()` used to build
parameters.

| Class | `action` | Fields |
|-------|----------|--------|
| `ClickAction({required String label, String? value})` | `click` | `label`, `value` |
| `ViewAction({String? label})` | `view` | `label` |
| `SetupAction(String status)` | `setup` | `status` |

### TrackingArea

Abstract base holding a `name`. `SplashArea` (`splash`) and `UnknownArea`
(`unknown`, the initial area) are provided. Changing the current area clears
the set of fired impression IDs (`triggeredImpressions`).

### TrackingDelegate

Base of `ScreenTrackingDelegate`. Holds the `TrackingReporter` and provides
`trackEvent(tracking)`, for tracking that is not tied to one screen.

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase` | `FbAnalyticsController`, which sends events to Firebase Analytics |
| `module_injector` | `ModuleConfigurator` and `ServiceLocator` for registration |
| `visibility_detector` | Visibility detection in `TrackingImpressionDetectorWidget` |
| `json_annotation` | Serialization of `TrackingAction` fields (code generated with `json_serializable`) |

## Testing

```bash
melos run test --scope=tracking
```

Or from `layer/tracking`:

```bash
flutter test
```

The package exports no test helpers; mock
`TrackingReporter` in consumer tests, for example with `mocktail`.
