/// Whether the user allows an [AppPermission].
enum AppPermissionStatus {
  /// Allowed, including a provisional or limited grant.
  granted,

  /// Not allowed yet; asking again shows the system prompt.
  denied,

  /// Not allowed, and the system no longer shows its prompt. Only the
  /// app's page in the device settings can allow it.
  permanentlyDenied;

  bool get isGranted => this == granted;
}
