import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

import '../../mock/utility/mock_screen_tracking_delegate.dart';

sealed class _TestEvent {
  const _TestEvent();
}

final class _ScreenVisibleEvent extends _TestEvent {
  const _ScreenVisibleEvent();
}

final class _ViewVisibleEvent extends _TestEvent {
  const _ViewVisibleEvent(this.trackingId);

  final String trackingId;
}

class _TestBloc extends Bloc<_TestEvent, int>
    with ScreenTrackingBlocMixin<_TestEvent, int> {
  _TestBloc(this.screenTrackingDelegate) : super(0) {
    trackScreenViewOn<_ScreenVisibleEvent>();
    trackViewEventOn<_ViewVisibleEvent>((event) => event.trackingId);
  }

  @override
  final ScreenTrackingDelegate screenTrackingDelegate;
}

void main() {
  group('ScreenTrackingBlocMixin', () {
    late MockScreenTrackingDelegate trackingDelegate;

    setUp(() => trackingDelegate = MockScreenTrackingDelegate());

    blocTest<_TestBloc, int>(
      'should track a screen view when the screen visible event is added',
      build: () => _TestBloc(trackingDelegate),
      act: (bloc) => bloc.add(const _ScreenVisibleEvent()),
      expect: () => const <int>[],
      verify: (_) => verify(trackingDelegate.trackScreenView).called(1),
    );

    blocTest<_TestBloc, int>(
      'should track a view event with the event label when a view becomes '
      'visible',
      build: () => _TestBloc(trackingDelegate),
      act: (bloc) => bloc.add(const _ViewVisibleEvent('loaded_content_view')),
      expect: () => const <int>[],
      verify: (_) => verify(
        () => trackingDelegate.trackViewEvent('loaded_content_view'),
      ).called(1),
    );
  });
}
