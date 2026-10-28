import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/footer_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../mock/feature/app_config/domain/use_case/mock_get_privacy_policy_url_use_case.dart';
import '../../../../../../mock/feature/app_config/domain/use_case/mock_get_terms_url_use_case.dart';
import '../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../mock/feature/profile/domain/use_case/mock_open_email_use_case.dart';
import '../../../../../../mock/feature/profile/presentation/widget/footer/tracking/mock_footer_tracking_delegate.dart';
import '../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../util/package_info_setup.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  final termsUrl = Uri.parse('https://legal.example.com/terms');
  final privacyPolicyUrl = Uri.parse(
    'https://legal.example.com/privacy-policy',
  );

  setUp(() async {
    await appServiceLocator.reset();
    registerTestPackageInfo();
  });

  tearDown(() async {
    await appServiceLocator.reset();
  });

  Future<MockOpenExternalUrlUseCase> pumpFooter(
    WidgetTester tester,
    List<PublishedAtEntity> stores,
  ) async {
    final openUrl = MockOpenExternalUrlUseCase()
      ..stubCall(const Right<OpenExternalUrlFailure, bool>(true));
    final bloc = FooterBloc(
      MockGetProfileUseCase(),
      openUrl,
      MockOpenEmailUseCase(),
      MockGetTermsUrlUseCase()
        ..stubCall(Right<GetTermsUrlFailure, Uri>(termsUrl)),
      MockGetPrivacyPolicyUrlUseCase()
        ..stubCall(Right<GetPrivacyPolicyUrlFailure, Uri>(privacyPolicyUrl)),
      MockFooterTrackingDelegate(),
    );
    appServiceLocator.registerFactory<FooterBloc>(() => bloc);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: FooterWidget(profile: createProfileEntity(publishedAt: stores)),
      ),
    );
    // The footer keeps animating, so it gets a fixed time to load.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return openUrl;
  }

  group('FooterWidget store links', () {
    testWidgets(
      'should hide store buttons and the heading when no store URL is available',
      (tester) async {
        await pumpFooter(tester, const [
          PublishedAtEntity(
            name: 'Website',
            url: 'https://portrai-96f2b.web.app/',
            image: '',
          ),
          PublishedAtEntity(name: 'Play Store', url: '', image: ''),
          PublishedAtEntity(name: 'App Store', url: '   ', image: ''),
        ]);

        final localizations = AppLocalizations.of(
          tester.element(find.byType(FooterWidget)),
        );
        expect(find.text(localizations.downloadTheApp), findsNothing);
        expect(find.text('Play Store'), findsNothing);
        expect(find.text('App Store'), findsNothing);
      },
      skip: !kIsWeb,
    );

    testWidgets(
      'should show only available store buttons when one store URL is present',
      (tester) async {
        await pumpFooter(tester, const [
          PublishedAtEntity(
            name: 'Website',
            url: 'https://portrai-96f2b.web.app/',
            image: '',
          ),
          PublishedAtEntity(
            name: 'Play Store',
            url:
                'https://play.google.com/store/apps/details?id=com.example.app',
            image: '',
          ),
          PublishedAtEntity(name: 'App Store', url: '', image: ''),
        ]);

        final localizations = AppLocalizations.of(
          tester.element(find.byType(FooterWidget)),
        );
        expect(find.text(localizations.downloadTheApp), findsOneWidget);
        expect(find.text('Play Store'), findsOneWidget);
        expect(find.text('App Store'), findsNothing);
        expect(find.text('Website'), findsNothing);
      },
      skip: !kIsWeb,
    );
  });

  group('FooterWidget legal links', () {
    setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

    for (final (label, url) in [
      ('termsAndConditions', termsUrl),
      ('privacyPolicy', privacyPolicyUrl),
    ]) {
      testWidgets('should open the configured page when $label is tapped', (
        tester,
      ) async {
        final openUrl = await pumpFooter(tester, const []);
        final localizations = AppLocalizations.of(
          tester.element(find.byType(FooterWidget)),
        );
        final text = label == 'termsAndConditions'
            ? localizations.termsAndConditions
            : localizations.privacyPolicy;

        await tester.ensureVisible(find.text(text));
        await tester.tap(find.text(text));
        await tester.pump();

        verify(
          () => openUrl(
            any(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri,
                'uri',
                url,
              ),
            ),
          ),
        ).called(1);
      });
    }
  });
}
