import 'package:core/core.dart';

/// Base sealed class for feature flag exceptions.
sealed class FeatureFlagException implements AppException {
  const FeatureFlagException();

  @override
  String toString() => 'FeatureFlagException: Operation failed';
}

final class FeatureFlagInitializationException extends FeatureFlagException {
  const FeatureFlagInitializationException();

  @override
  String toString() =>
      'FeatureFlagInitializationException: Initialization failed';
}

final class FeatureFlagUpdateException extends FeatureFlagException {
  const FeatureFlagUpdateException();

  @override
  String toString() => 'FeatureFlagUpdateException: Update failed';
}

final class FeatureFlagResetException extends FeatureFlagException {
  const FeatureFlagResetException();

  @override
  String toString() => 'FeatureFlagResetException: Reset failed';
}

final class EmptyFeatureFlagsException extends FeatureFlagException {
  const EmptyFeatureFlagsException();

  @override
  String toString() => 'EmptyFeatureFlagsException: No flags available';
}

final class FeatureFlagNotFoundException extends FeatureFlagException {
  const FeatureFlagNotFoundException(this._key);

  final String _key;

  @override
  String toString() => 'FeatureFlagNotFoundException: Key "$_key" not found';
}
