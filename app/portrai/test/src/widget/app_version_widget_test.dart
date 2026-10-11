import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/widget/app_version_widget.dart';

import '../../util/package_info_setup.dart';
import '../../util/test_wrapper_widget.dart';

void main() {
  setUp(() async {
    await appServiceLocator.reset();
    registerTestPackageInfo();
  });

  tearDown(() => appServiceLocator.reset());

  for (final onInverseSurface in [false, true]) {
    testWidgets(
      'should display the installed version when inverse surface is $onInverseSurface',
      (tester) async {
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: AppVersionWidget(onInverseSurface: onInverseSurface),
          ),
        );

        expect(find.textContaining('v1.0.1'), findsOneWidget);
        expect(find.textContaining('v1.0.0'), findsNothing);
      },
    );
  }
}
