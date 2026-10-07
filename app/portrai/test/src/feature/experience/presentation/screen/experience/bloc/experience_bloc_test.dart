import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/experience/domain/use_case/mock_get_experience_use_case.dart';
import '../../../../../../../mock/feature/experience/presentation/screen/experience/tracking/mock_experience_tracking_delegate.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
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

  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('ExperienceBloc', () {
    late MockGetExperienceUseCase getExperience;
    late MockGetProfileUseCase getProfile;
    late MockOpenExternalUrlUseCase openUrl;
    late MockExperienceTrackingDelegate tracking;

    ExperienceBloc buildBloc() =>
        ExperienceBloc(getExperience, getProfile, openUrl, tracking);

    setUp(() {
      getExperience = MockGetExperienceUseCase();
      getProfile = MockGetProfileUseCase();
      openUrl = MockOpenExternalUrlUseCase();
      tracking = MockExperienceTrackingDelegate();
    });

    blocTest<ExperienceBloc, ExperienceState>(
      'should emit loaded with no profile when the experience succeeds but profile fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
        getExperience.stubCall(
          experience.id,
          Right<GetExperienceFailure, ExperienceEntity>(experience),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadExperienceEvent(experience.id)),
      expect: () => [const LoadingState(), LoadedState(experience: experience)],
      verify: (_) {
        verify(() => getExperience(experience.id)).called(1);
      },
    );

    blocTest<ExperienceBloc, ExperienceState>(
      'should emit error when loading the experience fails',
      setUp: () {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );
        getExperience.stubCall(
          experience.id,
          const Left<GetExperienceFailure, ExperienceEntity>(
            ExperienceNotFoundFailure(),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadExperienceEvent(experience.id)),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<ExperienceNotFoundFailure>(),
        ),
      ],
    );

    blocTest<ExperienceBloc, ExperienceState>(
      'should open and track an external link when the URL opens successfully',
      setUp: () =>
          openUrl.stubCall(const Right<OpenExternalUrlFailure, bool>(true)),
      build: buildBloc,
      seed: () => LoadedState(experience: experience),
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(
          url: 'https://acme.example',
          label: 'Company',
        ),
      ),
      expect: () => const <ExperienceState>[],
      verify: (_) {
        verify(
          () => openUrl(
            any<OpenExternalUrlParam>(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri.toString(),
                'uri',
                'https://acme.example',
              ),
            ),
          ),
        ).called(1);
        verify(() => tracking.trackExternalLinkClick('Company')).called(1);
      },
    );

    blocTest<ExperienceBloc, ExperienceState>(
      'should not open a link when the experience has not loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(
          url: 'https://acme.example',
          label: 'Company',
        ),
      ),
      expect: () => const <ExperienceState>[],
      verify: (_) => verifyNever(() => openUrl(any())),
    );

    blocTest<ExperienceBloc, ExperienceState>(
      'should track screen and section impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(const SectionVisibleEvent('overview'));
        bloc.add(ViewStateVisibleEvent.success());
        bloc.add(const HeaderTabClickEvent('technologies'));
      },
      expect: () => const <ExperienceState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackViewEvent('overview')).called(1);
        verify(() => tracking.trackViewEvent('loaded_content_view')).called(1);
        verify(() => tracking.trackTabItemSelection('technologies')).called(1);
      },
    );
  });
}
