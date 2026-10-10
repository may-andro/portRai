import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_direct_answerer.dart';

void main() {
  final answerer = AssistantDirectAnswerer(
    jsonEncode({
      'profile': {'name': 'Mayank Rai', 'email': 'm@x.com', 'phone': '123'},
      'overview': [
        'Total time worked per country, overlapping roles counted once: Spain: 6 years and 10 months (A, B); India: 4 years (C, D).',
        'Experience per city, with time worked and roles: Hyderabad: 2 years and 11 months in 2 roles (C (Dev), D (Lead)); Pune: 2 years and 1 month in 1 role (E (Junior)).',
      ],
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

  test('should state the time in a city when asked how long', () {
    expect(
      answerer.answer('how long was hyderabad experience'),
      'Mayank Rai worked 2 years and 11 months in Hyderabad, across 2 roles: '
      'C (Dev), D (Lead).',
    );
    expect(
      answerer.answer('how long in pune?'),
      contains('2 years and 1 month'),
    );
  });

  test('should state the time in a country when asked how long', () {
    expect(
      answerer.answer('how many years in India'),
      'Mayank Rai worked 4 years in India (C, D).',
    );
  });

  test('should leave comparisons to the model when a place is mentioned', () {
    expect(answerer.answer('longest experience in India?'), isNull);
  });
}
