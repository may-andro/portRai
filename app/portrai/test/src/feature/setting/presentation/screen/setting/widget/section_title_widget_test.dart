import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/section_title_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SectionTitleWidget', () {
    testWidgets('should render the provided title when built', (tester) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: SectionTitleWidget(title: 'Settings Section'),
        ),
      );
      await tester.pump();

      expect(find.text('Settings Section'), findsOneWidget);
    });
  });
}
