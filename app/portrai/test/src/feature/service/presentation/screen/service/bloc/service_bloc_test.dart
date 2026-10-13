import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../../mock/feature/service/presentation/screen/service/tracking/mock_service_tracking_delegate.dart';

void main() {
  group('ServiceBloc', () {
    late MockGetProfileUseCase getProfileUseCase;
    late MockServiceTrackingDelegate trackingDelegate;

    setUp(() {
      getProfileUseCase = MockGetProfileUseCase();
      trackingDelegate = MockServiceTrackingDelegate();
    });

    test('should start in the loading state when created', () {
      expect(
        ServiceBloc(getProfileUseCase, trackingDelegate).state,
        const LoadingState(),
      );
    });

    blocTest<ServiceBloc, ServiceState>(
      'should track the screen when the screen becomes visible',
      build: () => ServiceBloc(getProfileUseCase, trackingDelegate),
      act: (bloc) => bloc.add(ScreenVisibleEvent()),
      expect: () => const <ServiceState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
      },
    );

    blocTest<ServiceBloc, ServiceState>(
      'should emit loaded when the profile is loaded',
      build: () {
        getProfileUseCase.stubCall(Right(createProfileEntity()));
        return ServiceBloc(getProfileUseCase, trackingDelegate);
      },
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [LoadedState(profile: createProfileEntity())],
    );

    blocTest<ServiceBloc, ServiceState>(
      'should stay loading when the profile cannot be loaded',
      build: () {
        getProfileUseCase.stubCall(const Left(ProfileNotFoundFailure()));
        return ServiceBloc(getProfileUseCase, trackingDelegate);
      },
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => const <ServiceState>[],
    );
  });
}
