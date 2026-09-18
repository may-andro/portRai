---
description: Use when adding analytics/tracking to a screen or user action in this Flutter workspace, to follow the ScreenTrackingDelegate + TrackingArea pattern instead of calling EventTracker directly from blocs or widgets.
---

# Tracking Event Conventions

Reference: `layer/tracking/README.md` for the underlying primitives
(`EventTracker`, `TrackingReporter`, `ScreenTrackingDelegate`, event types).
The README's own usage examples are generic/illustrative — the pattern
below is what the app actually does; follow the app's real pattern, not the
README's sample snippets.

## Per-screen tracking delegate

Every screen/feature that tracks events owns one
`<Screen>TrackingDelegate extends ScreenTrackingDelegate`, in
`presentation/screen/<screen_name>/tracking/<screen_name>_tracking_delegate.dart`
(exported from that screen's `tracking/_tracking.dart` barrel — see
`flutter-architecture-conventions` for the folder layout).

```dart
class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('experience');
}

@register
class ExperienceTrackingDelegate extends ScreenTrackingDelegate {
  ExperienceTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackTabItemSelection(String sectionName) {
    trackEvent(Tracking(name: 'header_tab', action: ClickAction(label: sectionName)));
  }
}
```

- `TrackingArea` is a private (`_`-prefixed) const subclass naming the
  screen/area (snake or lower-case words, e.g. `'experience'`,
  `'experiences'`) — it's an implementation detail of the delegate, not
  exported.
- The delegate is `@register`ed like any other class (see
  `module-injector-annotation-conventions`) and injected into the owning
  bloc's constructor, e.g. `final ExperienceTrackingDelegate _trackingDelegate;`.
- Expose one small, intention-revealing method per trackable action
  (`trackViewEvent`, `trackTabItemSelection`, `trackExternalLinkClick`), not
  a generic `track(event)` passthrough — callers in the bloc should never
  construct raw `Tracking`/`ViewTracking` objects themselves.
- Use `ViewTracking(label:)` for screen/section visibility events, and
  `Tracking(name:, action: ClickAction(label:))` for discrete user actions
  (taps, link clicks). Keep `name` values short/stable snake or lower-words
  identifiers (`'external_link'`, `'header_tab'`) since they become
  analytics event names.

## Wiring into a bloc

The bloc owns the delegate and calls its methods from the relevant event
handlers (e.g. call `trackViewEvent` on a `ScreenVisibleEvent`,
`trackTabItemSelection` on a `HeaderTabClickEvent`). Don't call tracking
methods from widgets directly — widgets only dispatch bloc events (see
`flutter-architecture-conventions`).

## Don't invent

Don't call `serviceLocator<EventTracker>()`/`TrackingReporter` directly
from a bloc or widget — always go through a screen-owned
`ScreenTrackingDelegate` subclass, even for a single event, so all of a
screen's tracking surface lives in one discoverable file.

## Related skills

- `flutter-architecture-conventions` — bloc event naming and the
  `tracking/` sub-folder position within a screen folder.
- `module-injector-annotation-conventions` — how the delegate itself gets
  registered and injected.
