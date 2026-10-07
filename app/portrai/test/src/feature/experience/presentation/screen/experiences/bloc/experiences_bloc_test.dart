import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/experience/domain/use_case/mock_get_experiences_use_case.dart';
import '../../../../../../../mock/feature/experience/presentation/screen/experiences/tracking/mock_experiences_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';

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
    late MockGetProfileUseCase getProfile;
    late MockExperiencesTrackingDelegate tracking;

    ExperiencesBloc buildBloc() =>
        ExperiencesBloc(getExperiences, getProfile, tracking);

    setUp(() {
      getExperiences = MockGetExperiencesUseCase();
      getProfile = MockGetProfileUseCase();
      tracking = MockExperiencesTrackingDelegate();
    });

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should emit loaded without a profile when experiences load but profile fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
        getExperiences.stubCall(
          Right<GetExperiencesFailure, List<ExperienceEntity>>([experience]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadExperiencesEvent()),
      expect: () => [
        const LoadingState(),
        LoadedState(experiences: [experience], profile: null),
      ],
    );

    blocTest<ExperiencesBloc, ExperiencesState>(
      'should emit error when loading experiences fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
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
        bloc.add(ViewStateVisibleEvent.success());
      },
      expect: () => const <ExperiencesState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackViewEvent('loaded_content_view')).called(1);
      },
    );
  });
}
