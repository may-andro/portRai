import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/profile/presentation/screen/profile/tracking/mock_profile_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final profile = createProfileEntity();

  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('ProfileBloc', () {
    late MockGetProfileUseCase getProfile;
    late MockOpenExternalUrlUseCase openUrl;
    late MockProfileTrackingDelegate tracking;

    ProfileBloc buildBloc() => ProfileBloc(getProfile, openUrl, tracking);

    setUp(() {
      getProfile = MockGetProfileUseCase();
      openUrl = MockOpenExternalUrlUseCase();
      tracking = MockProfileTrackingDelegate();
    });

    blocTest<ProfileBloc, ProfileState>(
      'should emit loading and loaded when loading the profile succeeds',
      setUp: () =>
          getProfile.stubCall(Right<GetProfileFailure, ProfileEntity>(profile)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [const LoadingState(), LoadedState(profile: profile)],
      verify: (_) => verify(() => getProfile()).called(1),
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit loading and error when loading the profile fails',
      setUp: () => getProfile.stubCall(
        const Left<GetProfileFailure, ProfileEntity>(ProfileNotFoundFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<ProfileNotFoundFailure>(),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should open and track an external link when the URL opens successfully',
      setUp: () =>
          openUrl.stubCall(const Right<OpenExternalUrlFailure, bool>(true)),
      build: buildBloc,
      seed: () => LoadedState(profile: profile),
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(url: 'https://example.com', label: 'Github'),
      ),
      expect: () => const <ProfileState>[],
      verify: (_) {
        verify(
          () => openUrl(
            any<OpenExternalUrlParam>(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri.toString(),
                'uri',
                'https://example.com',
              ),
            ),
          ),
        ).called(1);
        verify(() => tracking.trackExternalLinkClick('Github')).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should not open a link when the profile has not loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(url: 'https://example.com', label: 'Github'),
      ),
      expect: () => const <ProfileState>[],
      verify: (_) => verifyNever(() => openUrl(any())),
    );

    blocTest<ProfileBloc, ProfileState>(
      'should track the screen and view impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(ViewStateVisibleEvent.loading());
        bloc.add(ViewStateVisibleEvent.success());
        bloc.add(ViewStateVisibleEvent.error());
      },
      expect: () => const <ProfileState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackViewEvent('loading_content_view')).called(1);
        verify(() => tracking.trackViewEvent('loaded_content_view')).called(1);
        verify(() => tracking.trackViewEvent('error_content_view')).called(1);
      },
    );
  });
}
