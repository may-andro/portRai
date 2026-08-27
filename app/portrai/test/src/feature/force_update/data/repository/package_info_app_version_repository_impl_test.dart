import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portrai/src/feature/force_update/data/_data.dart';

void main() {
  group('PackageInfoAppVersionRepositoryImpl', () {
    late PackageInfoAppVersionRepositoryImpl repository;

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'PortRai',
        packageName: 'com.example.portrai',
        version: '1.2.3',
        buildNumber: '42',
        buildSignature: '',
      );
      repository = PackageInfoAppVersionRepositoryImpl();
    });

    test('should return the current app version', () async {
      final version = await repository.getCurrentAppVersion();

      expect(version, '1.2.3');
    });

    test('should return the package name', () async {
      final packageName = await repository.getPackageName();

      expect(packageName, 'com.example.portrai');
    });
  });
}
