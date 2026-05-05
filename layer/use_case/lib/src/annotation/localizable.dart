/// Annotation for marking failures that should have localized messages.
///
/// This annotation is used by the code generator to automatically create
/// a translator that maps failure types to localized messages.
///
/// Example usage:
/// ```dart
/// @Localizable('errorUserNotFound')
/// class UserNotFoundFailure extends BasicFailure {
///   const UserNotFoundFailure({super.cause});
/// }
/// ```
class Localizable {
  const Localizable(this.key);

  /// The localization key from AppLocalizations (e.g., 'errorUserNotFound')
  final String key;
}
