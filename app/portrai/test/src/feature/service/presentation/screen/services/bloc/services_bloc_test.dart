import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

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
    late MockServicesTrackingDelegate tracking;

    ServicesBloc buildBloc() => ServicesBloc(getServices, tracking);

    setUp(() {
      getServices = MockGetServicesUseCase();
      tracking = MockServicesTrackingDelegate();
    });

    test('should start in the loading state when created', () {
      expect(buildBloc().state, const LoadingState());
    });

    blocTest<ServicesBloc, ServicesState>(
      'should emit loaded when services load',
      setUp: () {
        getServices.stubCall(
          const Right<GetServicesFailure, List<ServiceEntity>>([service]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadServicesEvent()),
      expect: () => [
        const LoadingState(),
        const LoadedState(services: [service]),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'should emit error when loading services fails',
      setUp: () {
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

    blocTest<ServicesBloc, ServicesState>(
      'should track the opened item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ServiceClickEvent('App Development')),
      expect: () => const <ServicesState>[],
      verify: (_) =>
          verify(() => tracking.trackServiceClick('App Development')).called(1),
    );
  });
}
