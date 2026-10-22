import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/setting_screen.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import 'package:use_case/use_case.dart';

import '../../../../../../mock/feature/setting/presentation/screen/setting/bloc/mock_setting_bloc.dart';
import '../../../../../../util/package_info_setup.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SettingScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
      registerTestPackageInfo();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    for (final isDevMenuEnabled in [false, true]) {
      testWidgets(
        'should ${isDevMenuEnabled ? 'show' : 'hide'} the developer button when developer mode is ${isDevMenuEnabled ? 'enabled' : 'disabled'}',
        (tester) async {
          await tester.pumpWidget(
            TestWidgetWrapper(
              child: CustomScrollView(
                slivers: [
                  ContentWidget(
                    state: SettingLoadedState(
                      isLanguageSelectorEnabled: false,
                      isDevMenuEnabled: isDevMenuEnabled,
                    ),
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byType(DSButtonWidget),
            isDevMenuEnabled ? findsOneWidget : findsNothing,
          );
        },
      );
    }

    testWidgets(
      'should resolve the bloc from the service locator and dispatch the load event',
      (tester) async {
        final bloc = MockSettingBloc()..stubState(const SettingLoadingState());
        appServiceLocator.registerFactory<SettingBloc>(() => bloc);

        await tester.pumpWidget(
          const TestWidgetWrapper(child: SettingScreen()),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(const LoadSettingsEvent())).called(1);
      },
    );

    testWidgets('should render a loading indicator before loading starts', (
      tester,
    ) async {
      final bloc = MockSettingBloc()..stubState(const SettingInitialState());
      appServiceLocator.registerFactory<SettingBloc>(() => bloc);

      await tester.pumpWidget(const TestWidgetWrapper(child: SettingScreen()));
      await tester.pump();

      expect(find.byType(DSLoadingWidget), findsOneWidget);
    });

    testWidgets('should render an error card when loading fails', (
      tester,
    ) async {
      final bloc = MockSettingBloc()
        ..stubState(const SettingErrorState(UnknownFailure()));
      appServiceLocator.registerFactory<SettingBloc>(() => bloc);

      await tester.pumpWidget(const TestWidgetWrapper(child: SettingScreen()));
      await tester.pump();

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
    });

    testWidgets(
      'should scroll the settings followed by the footer when loading '
      'succeeds',
      (tester) async {
        final bloc = MockSettingBloc()
          ..stubState(
            const SettingLoadedState(isLanguageSelectorEnabled: false),
          );
        appServiceLocator.registerFactory<SettingBloc>(() => bloc);

        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: Text('footer'),
              child: SettingScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(ContentWidget),
          ),
          findsOneWidget,
        );
        expect(find.byType(FooterWidget), findsNothing);
        expect(find.byType(PageAppBarWidget), findsOneWidget);
        // The settings fill the screen, so the footer starts below it.
        final footer = find.text('footer', skipOffstage: false);
        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: footer,
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(footer).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(CustomScrollView)).dy,
          ),
        );
      },
    );
  });
}
