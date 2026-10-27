---
description: Use when adding analytics/tracking to a screen or user action in this Flutter workspace, to follow the ScreenTrackingDelegate + TrackingArea pattern instead of calling TrackingReporter directly from blocs or widgets.
---

# Tracking Event Conventions

Reference: `layer/tracking/README.md` for the underlying primitives
(`TrackingReporter`, `ScreenTrackingDelegate`, `Tracking` and its event types).
The README describes the layer's API; the pattern below is how the app uses it.

## Per-screen tracking delegate

Every screen/feature that tracks events owns one
`<Screen>TrackingDelegate extends ScreenTrackingDelegate`, in
`presentation/screen/<screen_name>/tracking/<screen_name>_tracking_delegate.dart`
(exported from that screen's `tracking/_tracking.dart` barrel — see
`flutter-architecture-conventions` for the folder layout). A tracked widget
that isn't a screen keeps its delegate in its own folder's `tracking/`
sub-folder, following the same non-screen exception as the folder layout
(e.g. `profile/presentation/widget/footer/tracking/`,
`force_update/presentation/tracking/`).

```dart
class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('portfolio');
}

@register
class PortfolioTrackingDelegate extends ScreenTrackingDelegate {
  PortfolioTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackSeeAllClick({required String label, required String sectionName}) {
    trackEvent(
      Tracking(
        name: 'see_all',
        action: ClickAction(label: label, value: sectionName),
      ),
    );
  }
}
```

(`app/portrai/lib/src/feature/portfolio/presentation/screen/portfolio/tracking/portfolio_tracking_delegate.dart`)

- `TrackingArea` is a private (`_`-prefixed) const subclass naming the
  screen/area (snake or lower-case words, e.g. `'experience'`,
  `'experiences'`) — it's an implementation detail of the delegate, not
  exported.
- The delegate is `@register`ed like any other class (see
  `module-injector-annotation-conventions`) and injected into the owning
  bloc's constructor, e.g. `final ExperienceTrackingDelegate _trackingDelegate;`.
- `ScreenTrackingDelegate` already provides `trackScreenView()` and
  `trackViewEvent(label)`; don't redeclare them in a screen delegate.
- Expose one small, intention-revealing method per other trackable action
  (`trackTabItemSelection`, `trackExternalLinkClick`), not
  a generic `track(event)` passthrough — callers in the bloc should never
  construct raw `Tracking`/`ViewTracking` objects themselves.
- Use `ViewTracking(label:)` for screen/section visibility events, and
  `Tracking(name:, action: ClickAction(label:, value:))` for discrete user
  actions (taps, link clicks). Keep `name` values short/stable snake or
  lower-words identifiers (`'external_link'`, `'see_all'`) since they become
  analytics event names. Fill `label` and `value` as described in
  [Click labels](#click-labels).

## Click labels

A click says what was tapped and, separately, what it was about.

- `ClickAction.label` names the tapped element in snake case as
  `<thing>_<element>`: `service_card`, `see_all_button`,
  `experience_see_more_button`, `feature_flags_row`. Never use a generic word
  such as `open`, and never put the item itself in the label.
- `ClickAction.value` carries the item the tap is about when there is one: its
  ID, or its title when it has no ID, or the section (`services`). Leave it out
  when the element stands alone, such as `setting_button`.
- When one item has several tap targets, each gets its own label, so the card
  and its See more button are `experience_card` and
  `experience_see_more_button`.
- The widget that handles the tap knows which element was tapped, so it passes
  the label, and the item when there is one, in the click event. The bloc
  forwards them to the delegate unchanged; don't map an enum to label strings
  in the bloc.

```dart
// Widget
context.bloc.add(
  ServiceClickEvent(label: 'service_card', serviceTitle: service.title),
);

// Bloc
void _mapServiceClickEventToState(
  ServiceClickEvent event,
  Emitter<ServiceListState> emit,
) => _trackingDelegate.trackServiceClick(
  label: event.label,
  serviceTitle: event.serviceTitle,
);
```

Delegate tests check the event `name`, the `click` action, the `label` and the
`value`.

## Wiring into a bloc

The bloc owns the delegate and calls its methods from the relevant event
handlers (e.g. `trackTabItemSelection` on a `HeaderTabClickEvent`). Screen views
and view events go through `ScreenTrackingBlocMixin`
(`app/portrai/lib/src/utility/screen_tracking_bloc_mixin.dart`): the bloc
overrides `screenTrackingDelegate` to return its delegate and registers
`trackScreenViewOn<ScreenVisibleEvent>()` and
`trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId)` in its
constructor, as `ExperienceBloc` does (see
`flutter-architecture-conventions`). Don't call tracking
methods from widgets directly — widgets only dispatch bloc events (see
`flutter-architecture-conventions`).

## Don't invent

Don't call `TrackingReporter.sendTrackingEvent` directly
from a bloc or widget — always go through a screen-owned
`ScreenTrackingDelegate` subclass, even for a single event, so all of a
screen's tracking surface lives in one discoverable file.

## Related skills

- `flutter-architecture-conventions` — bloc event naming and the
  `tracking/` sub-folder position within a screen folder.
- `module-injector-annotation-conventions` — how the delegate itself gets
  registered and injected.
