import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';

void main() {
  for (final exception in const <RemoteAssistantException>[
    RemoteAssistantPreferenceException(),
    RemoteAssistantClosedException(),
    RemoteAssistantConcurrentRequestException(),
    RemoteAssistantFlagException(),
    RemoteAssistantUnavailableException(),
    RemoteAssistantConsentRequiredException(),
    RemoteAssistantInvalidInputException(),
    RemoteAssistantTimeoutException(),
    RemoteAssistantCancelledException(),
    RemoteAssistantCallbackException(),
    RemoteAssistantIncompleteException(),
    RemoteAssistantResponseLimitException(),
  ]) {
    test(
      'should expose a content-safe AppException when formatting ${exception.runtimeType}',
      () {
        expect(exception, isA<AppException>());
        expect(
          exception.toString(),
          'RemoteAssistantException: operation failed',
        );
      },
    );
  }
}
