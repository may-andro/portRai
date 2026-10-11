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
    'should omit server messages from display when describing an exception',
    () {
      final error = handleAiException(
        ServerException('Response includes user content'),
        StackTrace.current,
      );
      expect(error.toString(), isNot(contains('user content')));
    },
  );
}
