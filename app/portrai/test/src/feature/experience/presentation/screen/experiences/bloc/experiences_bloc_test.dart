import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/experience/domain/use_case/mock_get_experiences_use_case.dart';
import '../../../../../../../mock/feature/experience/presentation/screen/experiences/tracking/mock_experiences_tracking_delegate.dart';

void main() {
  final experience = ExperienceEntity(
    company: 'Acme',
    position: 'Engineer',
    location: 'Amsterdam',
    startDate: DateTime(2024),
    endDate: null,
    current: true,
    employmentType: 'Full-time',
    description: 'Builds products',
    longDescription: 'Builds products for customers',
    responsibilities: const ['Coding'],
    achievements: const ['Shipped'],
    technologies: const ['Dart'],
    companyLogo: 'acme.png',
    url: null,
    id: 'acme-engineer',
  );

  group('ExperiencesBloc', () {
    late MockGetExperiencesUseCase getExperiences;
    late MockExperiencesTrackingDelegate tracking;

    ExperiencesBloc buildBloc() => ExperiencesBloc(getExperiences, tracking);

    setUp(() {
      getExperiences = MockGetExperiencesUseCase();
      tracking = MockExperiencesTrackingDelegate();
    });

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should emit loaded when experiences load',
      setUp: () {
        getExperiences.stubCall(
          Right<GetExperiencesFailure, List<ExperienceEntity>>([experience]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadExperiencesEvent()),
      expect: () => [
        const LoadingState(),
        LoadedState(experiences: [experience]),
      ],
    );

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should emit error when loading experiences fails',
      setUp: () {
        getExperiences.stubCall(
          const Left<GetExperiencesFailure, List<ExperienceEntity>>(
            ExperiencesNetworkFailure(),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadExperiencesEvent()),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<ExperiencesNetworkFailure>(),
        ),
      ],
    );

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should track screen and view when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(const ViewStateVisibleEvent('loaded_content_view'));
      },
      expect: () => const <ExperiencesState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackViewEvent('loaded_content_view')).called(1);
      },
    );

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should track the opened item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ExperienceClickEvent('experience_1')),
      expect: () => const <ExperiencesState>[],
      verify: (_) =>
          verify(() => tracking.trackExperienceClick('experience_1')).called(1),
    );
  });
}
