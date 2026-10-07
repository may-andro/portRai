import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';

import '../../../../../../../mock/feature/service/presentation/screen/services/tracking/mock_services_tracking_delegate.dart';

void main() {
  group('ServicesBloc', () {
    late MockServicesTrackingDelegate trackingDelegate;

    setUp(() {
      trackingDelegate = MockServicesTrackingDelegate();
    });

    test('should start in the loading state when created', () {
      expect(ServicesBloc(trackingDelegate).state, const LoadingState());
    });

    blocTest<ServicesBloc, ServicesState>(
      'should track the screen when the screen becomes visible',
      build: () => ServicesBloc(trackingDelegate),
      act: (bloc) => bloc.add(ScreenVisibleEvent()),
      expect: () => const <ServicesState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
      },
    );
  });
}
