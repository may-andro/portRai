import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';

import '../../../../../../../mock/feature/developer_mode/presentation/screen/developer_menu/tracking/mock_developer_menu_tracking_delegate.dart';

void main() {
  group('DeveloperMenuBloc', () {
    late MockDeveloperMenuTrackingDelegate trackingDelegate;

    DeveloperMenuBloc buildBloc() => DeveloperMenuBloc(trackingDelegate);

    setUp(() {
      trackingDelegate = MockDeveloperMenuTrackingDelegate();
    });

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should emit a loaded state when loading the menu',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDeveloperMenuEvent()),
      expect: () => const [DeveloperMenuLoadedState()],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should not emit a state change when crash simulation events are added',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ForceFatalCrashEvent());
        bloc.add(const ForceNonFatalCrashEvent());
        bloc.add(const ForceBlacklistErrorEvent());
      },
      expect: () => const <DeveloperMenuState>[],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should track the screen and content impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(ViewStateVisibleEvent.loading());
        bloc.add(ViewStateVisibleEvent.success());
        bloc.add(ViewStateVisibleEvent.error());
      },
      expect: () => const <DeveloperMenuState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
        verify(
          () => trackingDelegate.trackViewEvent(
            'developer_menu_loading_content_view',
          ),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent(
            'developer_menu_loaded_content_view',
          ),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent(
            'developer_menu_error_content_view',
          ),
        ).called(1);
      },
    );
  });
}
