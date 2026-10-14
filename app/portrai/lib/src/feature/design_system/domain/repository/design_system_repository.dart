import 'package:design_system/design_system.dart';

abstract class DesignSystemRepository {
  Future<DesignSystem?> getDesignSystem();

  Future<void> setDesignSystem(DesignSystem designSystem);

  Future<void> clearDesignSystem();
}
