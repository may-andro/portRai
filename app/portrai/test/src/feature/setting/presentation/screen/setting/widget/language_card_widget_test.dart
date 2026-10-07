import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/language_card_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('LanguageCardWidget', () {
    testWidgets(
      'should render the selected language label and the localized current language when built',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(child: LanguageCardWidget()),
        );
        await tester.pump();

        expect(find.text('Current Language'), findsOneWidget);
        expect(find.text('🇬🇧 English'), findsOneWidget);
      },
    );
  });
}
