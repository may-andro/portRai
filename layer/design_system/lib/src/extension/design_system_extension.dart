import 'package:design_system/src/design_system/beltane/beltane.dart';
import 'package:design_system/src/design_system/carnival/carnival.dart';
import 'package:design_system/src/design_system/chuseok/chuseok.dart';
import 'package:design_system/src/design_system/design_system.dart';
import 'package:design_system/src/design_system/diwali/diwali.dart';
import 'package:design_system/src/design_system/halloween/halloween.dart';
import 'package:design_system/src/design_system/hogeras/hogeras.dart';
import 'package:design_system/src/design_system/hogmanay/hogmanay.dart';
import 'package:design_system/src/design_system/holi/holi.dart';
import 'package:design_system/src/design_system/obon/obon.dart';
import 'package:design_system/src/design_system/pachamama/pachamama.dart';
import 'package:design_system/src/design_system/sakura/sakura.dart';
import 'package:design_system/src/design_system/xmas/xmas.dart';
import 'package:design_system/src/foundation/foundation.dart';

extension DesignSystemExtension on DesignSystem {
  DSColorPalette get darkColorPalette {
    switch (this) {
      case DesignSystem.beltane:
        return const BeltaneDarkColorPalette();
      case DesignSystem.carnival:
        return const CarnivalDarkColorPalette();
      case DesignSystem.chuseok:
        return const ChuseokDarkColorPalette();
      case DesignSystem.diwali:
        return const DiwaliDarkColorPalette();
      case DesignSystem.halloween:
        return const HalloweenDarkColorPalette();
      case DesignSystem.hogeras:
        return const HogerasDarkColorPalette();
      case DesignSystem.hogmanay:
        return const HogmanayDarkColorPalette();
      case DesignSystem.holi:
        return const HoliDarkColorPalette();
      case DesignSystem.obon:
        return const ObonDarkColorPalette();
      case DesignSystem.pachamama:
        return const PachamamaDarkColorPalette();
      case DesignSystem.sakura:
        return const SakuraDarkColorPalette();
      case DesignSystem.xmas:
        return const ChristmasDarkColorPalette();
    }
  }

  DSColorPalette get lightColorPalette {
    switch (this) {
      case DesignSystem.beltane:
        return const BeltaneLightColorPalette();
      case DesignSystem.carnival:
        return const CarnivalLightColorPalette();
      case DesignSystem.chuseok:
        return const ChuseokLightColorPalette();
      case DesignSystem.diwali:
        return const DiwaliLightColorPalette();
      case DesignSystem.halloween:
        return const HalloweenLightColorPalette();
      case DesignSystem.hogeras:
        return const HogerasLightColorPalette();
      case DesignSystem.hogmanay:
        return const HogmanayLightColorPalette();
      case DesignSystem.holi:
        return const HoliLightColorPalette();
      case DesignSystem.obon:
        return const ObonLightColorPalette();
      case DesignSystem.pachamama:
        return const PachamamaLightColorPalette();
      case DesignSystem.sakura:
        return const SakuraLightColorPalette();
      case DesignSystem.xmas:
        return const ChristmasLightColorPalette();
    }
  }

  DSDimen get dimen {
    switch (this) {
      case DesignSystem.beltane:
        return const BeltaneDimen();
      case DesignSystem.carnival:
        return const CarnivalDimen();
      case DesignSystem.chuseok:
        return const ChuseokDimen();
      case DesignSystem.diwali:
        return const DiwaliDimen();
      case DesignSystem.halloween:
        return const HalloweenDimen();
      case DesignSystem.hogeras:
        return const HogerasDimen();
      case DesignSystem.hogmanay:
        return const HogmanayDimen();
      case DesignSystem.holi:
        return const HoliDimen();
      case DesignSystem.obon:
        return const ObonDimen();
      case DesignSystem.pachamama:
        return const PachamamaDimen();
      case DesignSystem.sakura:
        return const SakuraDimen();
      case DesignSystem.xmas:
        return const ChristmasDimen();
    }
  }

  DSTypography get typography {
    switch (this) {
      case DesignSystem.beltane:
        return const BeltaneTypography();
      case DesignSystem.carnival:
        return const CarnivalTypography();
      case DesignSystem.chuseok:
        return const ChuseokTypography();
      case DesignSystem.diwali:
        return const DiwaliTypography();
      case DesignSystem.halloween:
        return const HalloweenTypography();
      case DesignSystem.hogeras:
        return const HogerasTypography();
      case DesignSystem.hogmanay:
        return const HogmanayTypography();
      case DesignSystem.holi:
        return const HoliTypography();
      case DesignSystem.obon:
        return const ObonTypography();
      case DesignSystem.pachamama:
        return const PachamamaTypography();
      case DesignSystem.sakura:
        return const SakuraTypography();
      case DesignSystem.xmas:
        return const ChristmasTypography();
    }
  }
}
