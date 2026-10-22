import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:portrai/src/feature/permission/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/permission/domain/_domain.dart';

@Register(as: PermissionRepository)
class PermissionHandlerPermissionRepository implements PermissionRepository {
  const PermissionHandlerPermissionRepository(
    this._permissionMapper,
    this._statusMapper,
  );

  final AppPermissionMapper _permissionMapper;
  final AppPermissionStatusMapper _statusMapper;

  // permission_handler supports notifications on Android and iOS only.
  @override
  bool isSupported(AppPermission permission) => switch (permission) {
    AppPermission.notifications =>
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS),
  };

  @override
  Future<AppPermissionStatus> status(AppPermission permission) async =>
      _statusMapper.map(await _permissionMapper.map(permission).status);

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async =>
      _statusMapper.map(await _permissionMapper.map(permission).request());

  @override
  Future<bool> openSettings() => handler.openAppSettings();
}
