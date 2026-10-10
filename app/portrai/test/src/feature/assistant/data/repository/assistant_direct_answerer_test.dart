import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_direct_answerer.dart';

void main() {
  final answerer = AssistantDirectAnswerer(
    jsonEncode({
      'profile': {'name': 'Mayank Rai', 'email': 'm@x.com', 'phone': '123'},
    }),
  );

  test('should return the email when asked for email', () {
    expect(answerer.answer('What is his email?'), contains('m@x.com'));
  });

  test('should return the phone when asked for the phone number', () {
    expect(answerer.answer('phone number?'), contains('123'));
  });

  test('should return both details when asked how to contact', () {
    final result = answerer.answer('How can I reach him?');
    expect(result, contains('m@x.com'));
    expect(result, contains('123'));
  });

  test('should return null when the question needs the model', () {
    expect(answerer.answer('longest experience?'), isNull);
    expect(answerer.answer('which company in 2022'), isNull);
  });
}
