import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/job_opening/job_opening.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../../mock/feature/setting/presentation/screen/setting/bloc/mock_setting_bloc.dart';
import '../../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../../util/package_info_setup.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);
  setUp(() async {
    await appServiceLocator.reset();
    registerTestPackageInfo();
  });

  tearDown(() => appServiceLocator.reset());

  Future<void> pumpContent(
    WidgetTester tester,
    SettingLoadedState state,
  ) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: CustomScrollView(slivers: [ContentWidget(state: state)]),
      ),
    );
    await tester.pump();
  }

  group('Setting ContentWidget', () {
    for (final (label, cardTitle, entryName, routeName, routePath) in [
      (
        'theme',
        'App theme',
        'theme',
        DesignSystemModuleRoute.designSystemGallery.name,
        DesignSystemModuleRoute.designSystemGallery.path,
      ),
      (
        'job openings',
        'Job openings',
        'job_openings',
        JobOpeningModuleRoute.jobOpenings.name,
        JobOpeningModuleRoute.jobOpenings.path,
      ),
    ]) {
      testWidgets('should track the tap and open the screen when the $label '
          'card is tapped', (tester) async {
        final bloc = MockSettingBloc()..stubState(const SettingLoadingState());
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider<SettingBloc>.value(
                value: bloc,
                child: const Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      ContentWidget(
                        state: SettingLoadedState(
                          isLanguageSelectorEnabled: false,
                          isJobOpeningsEnabled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GoRoute(
              name: routeName,
              path: routePath,
              builder: (_, _) => const Text('Opened screen'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
        );
        await tester.pump();

        await tester.tap(find.text(cardTitle));
        await tester.pumpAndSettle();

        verify(() => bloc.add(SettingEntryClickEvent(entryName))).called(1);
        expect(find.text('Opened screen'), findsOneWidget);
      });
    }

    testWidgets('should always show the theme section', (tester) async {
      await pumpContent(
        tester,
        const SettingLoadedState(isLanguageSelectorEnabled: false),
      );

      expect(find.text('Theme'), findsOneWidget);
      expect(find.byType(DesignSystemCardWidget), findsOneWidget);
    });

    for (final isJobOpeningsEnabled in [true, false]) {
      testWidgets('should show the job openings card only when its flag is '
          'on, when the flag is $isJobOpeningsEnabled', (tester) async {
        await pumpContent(
          tester,
          SettingLoadedState(
            isLanguageSelectorEnabled: false,
            isJobOpeningsEnabled: isJobOpeningsEnabled,
          ),
        );

        expect(
          find.byType(JobOpeningsCardWidget),
          isJobOpeningsEnabled ? findsOneWidget : findsNothing,
        );
      });
    }

    testWidgets('should show the AI section when the feature flag is on', (
      tester,
    ) async {
      AssistantTestFixture(remoteRollout: false).install();
      await pumpContent(
        tester,
        const SettingLoadedState(
          isLanguageSelectorEnabled: false,
          isLocalAssistantAvailable: true,
        ),
      );

      expect(find.text('Portfolio AI'), findsOneWidget);
    });

    testWidgets('should hide the AI section when the feature flag is off', (
      tester,
    ) async {
      await pumpContent(
        tester,
        const SettingLoadedState(isLanguageSelectorEnabled: false),
      );

      expect(find.text('Portfolio AI'), findsNothing);
    });

    testWidgets(
      'should render the language section and developer mode button when both are enabled',
      (tester) async {
        await pumpContent(
          tester,
          const SettingLoadedState(
            isLanguageSelectorEnabled: true,
            isDevMenuEnabled: true,
          ),
        );

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Current Language'), findsOneWidget);
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'should hide the language section when the selector is disabled and developer mode is enabled',
      (tester) async {
        await pumpContent(
          tester,
          const SettingLoadedState(
            isLanguageSelectorEnabled: false,
            isDevMenuEnabled: true,
          ),
        );

        expect(find.text('Language'), findsNothing);
        expect(find.text('Current Language'), findsNothing);
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'should hide developer mode when disabled while the language selector is enabled',
      (tester) async {
        await pumpContent(
          tester,
          const SettingLoadedState(isLanguageSelectorEnabled: true),
        );

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Current Language'), findsOneWidget);
        expect(find.text('Developer Mode'), findsNothing);
      },
    );
  });
}
