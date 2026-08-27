abstract class AppVersionRepository {
  /// The version of the app currently running on the device (e.g. "1.2.3").
  Future<String> getCurrentAppVersion();

  /// The platform-specific package/bundle identifier of the app.
  Future<String> getPackageName();
}
