import 'package:package_info_plus/package_info_plus.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

void registerTestPackageInfo() {
  appServiceLocator.registerSingleton(
    () => PackageInfo(
      appName: 'portrai',
      packageName: 'com.mayandro.portrai',
      version: '1.0.1',
      buildNumber: '13',
    ),
  );
}
