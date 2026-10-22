import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/service/domain/use_case/mock_get_services_use_case.dart';
import '../../../../../../../mock/feature/service/presentation/screen/services/tracking/mock_services_tracking_delegate.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('ServicesBloc', () {
    late MockGetServicesUseCase getServices;
    late MockGetProfileUseCase getProfile;
    late MockServicesTrackingDelegate tracking;

    ServicesBloc buildBloc() => ServicesBloc(getServices, getProfile, tracking);

    setUp(() {
      getServices = MockGetServicesUseCase();
      getProfile = MockGetProfileUseCase();
      tracking = MockServicesTrackingDelegate();
    });

    test('should start in the loading state when created', () {
      expect(buildBloc().state, const LoadingState());
    });

    blocTest<ServicesBloc, ServicesState>(
      'should emit loaded without a profile when services load but profile fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
        getServices.stubCall(
          const Right<GetServicesFailure, List<ServiceEntity>>([service]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadServicesEvent()),
      expect: () => [
        const LoadingState(),
        const LoadedState(services: [service], profile: null),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'should emit error when loading services fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
        getServices.stubCall(
          const Left<GetServicesFailure, List<ServiceEntity>>(
            ServicesNetworkFailure(),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadServicesEvent()),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<ServicesNetworkFailure>(),
        ),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'should track screen and view when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(const ViewStateVisibleEvent('loaded_content_view'));
      },
      expect: () => const <ServicesState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackViewEvent('loaded_content_view')).called(1);
      },
    );
  });
}
