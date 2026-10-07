import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/splash/presentation/widget/setup_status_info_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SetupStatusInfoWidget', () {
    testWidgets('should render every localized setup status label when built', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: SetupStatusInfoWidget([
            InjectionStatus.start,
            InjectionStatus.register,
            InjectionStatus.postRegister,
            InjectionStatus.finished,
          ]),
        ),
      );

      expect(find.text('Starting initialization'), findsOneWidget);
      expect(find.text('Registering dependencies'), findsOneWidget);
      expect(find.text('Finalizing setup'), findsOneWidget);
      expect(find.text('Setup complete'), findsOneWidget);
    });
  });
}
