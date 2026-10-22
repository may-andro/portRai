import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';

abstract interface class PermissionRepository {
  /// Whether this platform has [permission] to ask for.
  bool isSupported(AppPermission permission);

  /// The current status of [permission], without asking the user.
  Future<AppPermissionStatus> status(AppPermission permission);

  /// Shows the system prompt for [permission] and returns the user's answer.
  Future<AppPermissionStatus> request(AppPermission permission);

  /// Opens the app's page in the device settings; returns whether it opened.
  Future<bool> openSettings();
}
