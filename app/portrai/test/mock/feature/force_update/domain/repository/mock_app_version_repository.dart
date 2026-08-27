import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';

class MockAppVersionRepository extends Mock implements AppVersionRepository {}

extension MockAppVersionRepositoryStub on MockAppVersionRepository {
  /// Stubs `getCurrentAppVersion()` to return [version].
  void stubGetCurrentAppVersion(String version) {
    when(getCurrentAppVersion).thenAnswer((_) async => version);
  }

  /// Stubs `getCurrentAppVersion()` to throw [error].
  void stubGetCurrentAppVersionThrows(Object error) {
    when(getCurrentAppVersion).thenThrow(error);
  }

  /// Stubs `getPackageName()` to return [packageName].
  void stubGetPackageName(String packageName) {
    when(getPackageName).thenAnswer((_) async => packageName);
  }

  /// Stubs `getPackageName()` to throw [error].
  void stubGetPackageNameThrows(Object error) {
    when(getPackageName).thenThrow(error);
  }
}
