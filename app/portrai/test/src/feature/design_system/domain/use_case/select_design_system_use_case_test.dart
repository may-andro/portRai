import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

void main() {
  group('SelectDesignSystemUseCase', () {
    test(
      'should return the design system assigned to the current month',
      () async {
        final expected = switch (DateTime.now().month) {
          DateTime.january => DesignSystem.hogmanay,
          DateTime.february => DesignSystem.carnival,
          DateTime.march => DesignSystem.holi,
          DateTime.april => DesignSystem.sakura,
          DateTime.may => DesignSystem.beltane,
          DateTime.june => DesignSystem.hogeras,
          DateTime.july => DesignSystem.obon,
          DateTime.august => DesignSystem.pachamama,
          DateTime.september => DesignSystem.chuseok,
          DateTime.october => DesignSystem.halloween,
          DateTime.november => DesignSystem.diwali,
          _ => DesignSystem.xmas,
        };

        final designSystemEither = await SelectDesignSystemUseCase().call();

        expect(designSystemEither.right, expected);
      },
    );
  });
}
