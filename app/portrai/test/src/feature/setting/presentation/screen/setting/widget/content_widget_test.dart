import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

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

  group('Setting ContentWidget', () {
    testWidgets('should show the AI section when the feature flag is on', (
      tester,
    ) async {
      AssistantTestFixture(remoteRollout: false).install();
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ContentWidget(
            state: SettingLoadedState(
              isLanguageSelectorEnabled: false,
              isLocalAssistantAvailable: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Portfolio AI'), findsOneWidget);
    });

    testWidgets('should hide the AI section when the feature flag is off', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ContentWidget(
            state: SettingLoadedState(isLanguageSelectorEnabled: false),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Portfolio AI'), findsNothing);
    });

    testWidgets(
      'should render the language section and developer mode button when both are enabled',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: ContentWidget(
              state: SettingLoadedState(
                isLanguageSelectorEnabled: true,
                isDevMenuEnabled: true,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Current Language'), findsOneWidget);
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'should hide the language section when the selector is disabled and developer mode is enabled',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: ContentWidget(
              state: SettingLoadedState(
                isLanguageSelectorEnabled: false,
                isDevMenuEnabled: true,
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Language'), findsNothing);
        expect(find.text('Current Language'), findsNothing);
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'should hide developer mode when disabled while the language selector is enabled',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: ContentWidget(
              state: SettingLoadedState(isLanguageSelectorEnabled: true),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Current Language'), findsOneWidget);
        expect(find.text('Developer Mode'), findsNothing);
      },
    );
  });
}
