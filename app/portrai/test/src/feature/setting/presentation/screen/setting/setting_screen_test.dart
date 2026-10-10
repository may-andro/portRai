import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/setting_screen.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/setting/presentation/screen/setting/bloc/mock_setting_bloc.dart';
import '../../../../../../util/assistant_bloc_scope.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SettingScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
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
              child: AssistantBlocScope(
                child: ContentWidget(
                  state: SettingLoadedState(
                    isLanguageSelectorEnabled: false,
                    isDevMenuEnabled: isDevMenuEnabled,
                  ),
                ),
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
          const TestWidgetWrapper(
            child: AssistantBlocScope(child: SettingScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(const LoadSettingsEvent())).called(1);
      },
    );
  });
}
