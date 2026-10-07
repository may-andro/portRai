import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';

import '../../../../../../../mock/feature/service/presentation/screen/service/tracking/mock_service_tracking_delegate.dart';

void main() {
  group('ServiceBloc', () {
    late MockServiceTrackingDelegate trackingDelegate;

    setUp(() {
      trackingDelegate = MockServiceTrackingDelegate();
    });

    test('should start in the loading state when created', () {
      expect(ServiceBloc(trackingDelegate).state, const LoadingState());
    });

    blocTest<ServiceBloc, ServiceState>(
      'should track the screen when the screen becomes visible',
      build: () => ServiceBloc(trackingDelegate),
      act: (bloc) => bloc.add(ScreenVisibleEvent()),
      expect: () => const <ServiceState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
      },
    );
  });
}
