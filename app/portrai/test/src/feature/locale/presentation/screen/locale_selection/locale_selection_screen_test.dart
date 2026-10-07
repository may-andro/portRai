import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/locale_selection_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../mock/feature/locale/presentation/screen/locale_selection/bloc/mock_locale_selection_bloc.dart';
import '../../../../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('LocaleSelectionScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [routeObserver],
          builder: (_, child) {
            return DSThemeBuilderWidget(
              brightness: Brightness.light,
              designSystem: DesignSystem.beltane,
              child: child!,
            );
          },
          home: const LocaleSelectionScreen(),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should resolve the bloc from the service locator and dispatch the load event',
      (tester) async {
        final bloc = MockLocaleSelectionBloc()..stubState(const LoadingState());
        appServiceLocator.registerFactory<LocaleSelectionBloc>(() => bloc);

        await pumpScreen(tester);

        verify(() => bloc.add(const LoadLocaleEvent())).called(1);
      },
    );

    testWidgets(
      'should show a localized snack bar when the locale update fails',
      (tester) async {
        final initialState = LocaleSelectionStateFactory.loaded(
          supportedLocales: createSupportedLocales(),
          appLocale: createEnglishLocale(),
        );
        final failureState = LocaleSelectionStateFactory.updateFailure(
          supportedLocales: createSupportedLocales(),
          appLocale: createEnglishLocale(),
          targetLocale: createSpanishLocale(),
          failure: const UpdateLocaleUnknownFailure(),
        );
        final bloc = MockLocaleSelectionBloc()
          ..stubStateStream(
            initialState: initialState,
            states: Stream<LocaleSelectionState>.fromIterable([
              initialState,
              failureState,
            ]),
          );
        appServiceLocator.registerFactory<LocaleSelectionBloc>(() => bloc);

        await pumpScreen(tester);
        await tester.pump();
        await tester.pump();

        expect(find.text('Failed to update language settings'), findsOneWidget);
      },
    );
  });
}
