import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking/tracking.dart';

/// Tracks a screen's views through [screenTrackingDelegate].
///
/// Register the screen's tracking events in the bloc constructor:
///
/// ```dart
/// trackScreenViewOn<ScreenVisibleEvent>();
/// trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
/// ```
mixin ScreenTrackingBlocMixin<E, S> on Bloc<E, S> {
  ScreenTrackingDelegate get screenTrackingDelegate;

  /// Tracks a screen view for every [T] event.
  void trackScreenViewOn<T extends E>() {
    on<T>((_, _) => screenTrackingDelegate.trackScreenView());
  }

  /// Tracks a view event labelled by [labelOf] for every [T] event.
  void trackViewEventOn<T extends E>(String Function(T event) labelOf) {
    on<T>((event, _) => screenTrackingDelegate.trackViewEvent(labelOf(event)));
  }
}
