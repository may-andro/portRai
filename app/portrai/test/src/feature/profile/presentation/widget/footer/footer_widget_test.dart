import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/footer_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../mock/feature/profile/domain/use_case/mock_open_email_use_case.dart';
import '../../../../../../mock/feature/profile/presentation/widget/footer/tracking/mock_footer_tracking_delegate.dart';
import '../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() async {
    await appServiceLocator.reset();
  });

  tearDown(() async {
    await appServiceLocator.reset();
  });

  Future<void> pumpFooter(
    WidgetTester tester,
    List<PublishedAtEntity> stores,
  ) async {
    final bloc = FooterBloc(
      MockOpenExternalUrlUseCase(),
      MockOpenEmailUseCase(),
      MockFooterTrackingDelegate(),
    );
    appServiceLocator.registerFactory<FooterBloc>(() => bloc);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: FooterWidget(profile: createProfileEntity(publishedAt: stores)),
      ),
    );
    await tester.pumpAndSettle();
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
}
