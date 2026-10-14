import 'package:design_system/design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/domain/repository/design_system_repository.dart';

class MockDesignSystemRepository extends Mock
    implements DesignSystemRepository {}

extension MockDesignSystemRepositoryStub on MockDesignSystemRepository {
  void stubSetDesignSystem(DesignSystem designSystem) {
    when(() => setDesignSystem(designSystem)).thenAnswer((_) async {});
  }

  void stubSetDesignSystemThrows(DesignSystem designSystem, Object error) {
    when(() => setDesignSystem(designSystem)).thenThrow(error);
  }

  void stubClearDesignSystem() {
    when(clearDesignSystem).thenAnswer((_) async {});
  }

  void stubClearDesignSystemThrows(Object error) {
    when(clearDesignSystem).thenThrow(error);
  }
}
