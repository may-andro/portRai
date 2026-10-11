import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

void main() {
  final cases = <(Object, Matcher)>[
    (InvalidApiKey('Invalid'), isA<AiConfigurationException>()),
    (ServiceApiNotEnabled('project'), isA<AiConfigurationException>()),
    (QuotaExceeded('Quota'), isA<AiQuotaExceededException>()),
    (UnsupportedUserLocation(), isA<AiUnsupportedLocationException>()),
    (ServerException('Server'), isA<AiServerException>()),
    (FirebaseAIException('Request failed'), isA<AiServerException>()),
    (FirebaseAISdkException('Parsing failed'), isA<AiSdkException>()),
    (ClientException('Disconnected'), isA<AiNetworkException>()),
    (TimeoutException('Timeout'), isA<AiTimeoutException>()),
  ];

  for (final (error, matcher) in cases) {
    test(
      'should map the concrete exception when the SDK throws ${error.runtimeType}',
      () {
        final stack = StackTrace.current;
        final mapped = handleAiException(error, stack);
        expect(mapped, matcher);
        expect(mapped.cause, same(error));
        expect(mapped.stackTrace, same(stack));
        expect(
          mapped.serviceMessage,
          error is FirebaseAIException ? error.message : null,
        );
      },
    );
  }

  test('should preserve existing layer exceptions when mapped again', () {
    final error = AiEmptyResponseException(
      StateError('Empty'),
      StackTrace.current,
    );
    expect(handleAiException(error, StackTrace.current), same(error));
  });

  test(
    'should omit service details from logs when describing an exception',
    () {
      final error = handleAiException(
        ServerException('Response includes user content'),
        StackTrace.current,
      );
      expect(error.toString(), isNot(contains('user content')));
      expect(error.serviceMessage, 'Response includes user content');
    },
  );

  for (final message in [
    'Your credits are depleted. Enable billing to continue.',
    'Gemini API has not been used in this project or it is disabled.',
    'Model gemini-unavailable is not found for API version v1beta.',
  ]) {
    test(
      'should retain actionable details when the server reports $message',
      () {
        final error = handleAiException(
          ServerException(message),
          StackTrace.current,
        );
        expect(error, isA<AiServerException>());
        expect(error.serviceMessage, message);
        expect(error.toString(), 'AiException: Firebase AI request failed');
      },
    );
  }

  for (final error in <Object>[
    StateError('secret prompt and response'),
    FirebaseAISdkException('Unhandled format: secret prompt and response'),
    ClientException(
      'secret body',
      Uri.parse('https://example.com/secret-prompt'),
    ),
    TimeoutException('secret prompt'),
    AiBlockedResponseException('secret response', StackTrace.current),
    AiEmptyResponseException('secret response', StackTrace.current),
    AiIncompleteResponseException('secret response', StackTrace.current),
  ]) {
    test('should omit unsafe details when mapping ${error.runtimeType}', () {
      final mapped = handleAiException(error, StackTrace.current);
      expect(mapped.serviceMessage, isNull);
      expect(mapped.toString(), isNot(contains('secret')));
    });
  }
}
