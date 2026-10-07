import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('Setting ContentWidget', () {
    testWidgets(
      'should render the language section and developer mode button when the selector is enabled',
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
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'should hide the language section when the selector is disabled',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: ContentWidget(
              state: SettingLoadedState(isLanguageSelectorEnabled: false),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Language'), findsNothing);
        expect(find.text('Current Language'), findsNothing);
        expect(find.text('Developer Mode'), findsOneWidget);
      },
    );
  });
}
