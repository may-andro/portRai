import 'dart:async';

import 'package:module_injector/module_injector.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portrai/src/feature/force_update/domain/repository/app_version_repository.dart';

@Register(as: AppVersionRepository)
class PackageInfoAppVersionRepositoryImpl implements AppVersionRepository {
  // Caches the lookup future so concurrent callers await the same platform
  // channel call instead of each starting their own.
  Future<PackageInfo>? _packageInfoFuture;

  Future<PackageInfo> get _packageInfo =>
      _packageInfoFuture ??= PackageInfo.fromPlatform();

  @override
  Future<String> getCurrentAppVersion() async => (await _packageInfo).version;

  @override
  Future<String> getPackageName() async => (await _packageInfo).packageName;
}
