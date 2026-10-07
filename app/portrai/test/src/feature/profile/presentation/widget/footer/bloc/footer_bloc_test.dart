import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_open_email_use_case.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/footer/tracking/mock_footer_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final profile = createProfileEntity();

  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('FooterBloc', () {
    late MockOpenExternalUrlUseCase openUrl;
    late MockOpenEmailUseCase openEmail;
    late MockFooterTrackingDelegate tracking;

    FooterBloc buildBloc() => FooterBloc(openUrl, openEmail, tracking);

    setUp(() {
      openUrl = MockOpenExternalUrlUseCase();
      openEmail = MockOpenEmailUseCase();
      tracking = MockFooterTrackingDelegate();
    });

    blocTest<FooterBloc, FooterState>(
      'should emit loaded when load data is added',
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDataEvent(profile: profile)),
      expect: () => [LoadedState(profile: profile)],
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
  });
}
