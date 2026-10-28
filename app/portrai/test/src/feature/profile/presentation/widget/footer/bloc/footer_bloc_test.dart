import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/app_config/domain/use_case/mock_get_privacy_policy_url_use_case.dart';
import '../../../../../../../mock/feature/app_config/domain/use_case/mock_get_terms_url_use_case.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_open_email_use_case.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/footer/tracking/mock_footer_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final termsUrl = Uri.parse('https://legal.example.com/terms');
  final privacyPolicyUrl = Uri.parse(
    'https://legal.example.com/privacy-policy',
  );
  final profile = createProfileEntity();

  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('FooterBloc', () {
    late MockGetProfileUseCase getProfile;
    late MockOpenExternalUrlUseCase openUrl;
    late MockOpenEmailUseCase openEmail;
    late MockGetTermsUrlUseCase getTermsUrl;
    late MockGetPrivacyPolicyUrlUseCase getPrivacyPolicyUrl;
    late MockFooterTrackingDelegate tracking;

    FooterBloc buildBloc() => FooterBloc(
      getProfile,
      openUrl,
      openEmail,
      getTermsUrl,
      getPrivacyPolicyUrl,
      tracking,
    );

    setUp(() {
      getProfile = MockGetProfileUseCase();
      openUrl = MockOpenExternalUrlUseCase();
      openEmail = MockOpenEmailUseCase();
      getTermsUrl = MockGetTermsUrlUseCase()
        ..stubCall(Right<GetTermsUrlFailure, Uri>(termsUrl));
      getPrivacyPolicyUrl = MockGetPrivacyPolicyUrlUseCase()
        ..stubCall(Right<GetPrivacyPolicyUrlFailure, Uri>(privacyPolicyUrl));
      tracking = MockFooterTrackingDelegate();
    });

    blocTest<FooterBloc, FooterState>(
      'should emit loaded when load data is added',
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDataEvent(profile: profile)),
      expect: () => [
        LoadedState(
          profile: profile,
          termsUrl: termsUrl,
          privacyPolicyUrl: privacyPolicyUrl,
        ),
      ],
      verify: (_) => verifyNever(() => getProfile()),
    );

    blocTest<FooterBloc, FooterState>(
      'should load without a legal link that cannot be read',
      setUp: () => getTermsUrl.stubCall(
        const Left<GetTermsUrlFailure, Uri>(GetTermsUrlUnknownFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDataEvent(profile: profile)),
      expect: () => [
        LoadedState(profile: profile, privacyPolicyUrl: privacyPolicyUrl),
      ],
    );

    blocTest<FooterBloc, FooterState>(
      'should load the profile itself when load data has no profile',
      setUp: () =>
          getProfile.stubCall(Right<GetProfileFailure, ProfileEntity>(profile)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDataEvent()),
      expect: () => [
        LoadedState(
          profile: profile,
          termsUrl: termsUrl,
          privacyPolicyUrl: privacyPolicyUrl,
        ),
      ],
    );

    blocTest<FooterBloc, FooterState>(
      'should emit unavailable when the profile cannot be loaded',
      setUp: () => getProfile.stubCall(
        const Left<GetProfileFailure, ProfileEntity>(ProfileNotFoundFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDataEvent()),
      expect: () => const [UnavailableState()],
    );

    blocTest<FooterBloc, FooterState>(
      'should open and track an external link when the URL opens successfully',
      setUp: () =>
          openUrl.stubCall(const Right<OpenExternalUrlFailure, bool>(true)),
      build: buildBloc,
      seed: () => LoadedState(profile: profile),
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(url: 'https://example.com', label: 'Resume'),
      ),
      expect: () => const <FooterState>[],
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
        verify(() => tracking.trackExternalLinkClick('Resume')).called(1);
      },
    );

    blocTest<FooterBloc, FooterState>(
      'should open and track an email client when the email opens successfully',
      setUp: () => openEmail.stubCall(
        profile.email,
        const Right<OpenEmailFailure, bool>(true),
      ),
      build: buildBloc,
      seed: () => LoadedState(profile: profile),
      act: (bloc) => bloc.add(OpenEmailClientEvent(profile.email)),
      expect: () => const <FooterState>[],
      verify: (_) {
        verify(() => openEmail(profile.email)).called(1);
        verify(() => tracking.trackEmailClick(profile.email)).called(1);
      },
    );

    blocTest<FooterBloc, FooterState>(
      'should ignore open actions when the footer has not loaded',
      build: buildBloc,
      act: (bloc) {
        bloc.add(
          const OpenExternalUrlEvent(
            url: 'https://example.com',
            label: 'Resume',
          ),
        );
        bloc.add(const OpenEmailClientEvent('mayank271993@gmail.com'));
      },
      expect: () => const <FooterState>[],
      verify: (_) {
        verifyNever(() => openUrl(any()));
        verifyNever(() => openEmail(any()));
      },
    );

    blocTest<FooterBloc, FooterState>(
      'should track the resume tap without changing the state when the '
      'resume is opened',
      build: buildBloc,
      act: (bloc) => bloc.add(const ResumeClickEvent('footer_resume_button')),
      expect: () => const <FooterState>[],
      verify: (_) => verify(
        () => tracking.trackResumeClick('footer_resume_button'),
      ).called(1),
    );
  });
}
