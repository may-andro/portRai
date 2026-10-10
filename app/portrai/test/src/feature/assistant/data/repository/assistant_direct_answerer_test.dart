import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_direct_answerer.dart';

void main() {
  final answerer = AssistantDirectAnswerer(
    jsonEncode({
      'profile': {'name': 'Mayank Rai', 'email': 'm@x.com', 'phone': '123'},
      'overview': [
        'Total time worked per country, overlapping roles counted once: Spain: 6 years and 10 months (A, B); India: 4 years (C, D).',
        'Career overview: 8 roles at 7 different companies.',
        'Longest role: Initech, 2 years.',
        'Shortest role: Acme, 2 months.',
        'First role (earliest start): Acme, July 2015.',
        'Current role: Lead at Initech since April 2024.',
        'Time using each technology across all roles, overlapping roles counted once (technologies listed on the roles): Flutter: 5 years and 2 months; Android: 4 years.',
        'Career gaps: none, there is no month without a role. Job changes: 3.',
        'Leadership roles: Tech Lead at Initech.',
        'Spoken languages (2): English (Fluent), Spanish (Proficient). No other spoken languages are listed.',
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
    expect(answerer.answer('tell me about his projects'), isNull);
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

  test(
    'should state the time using a technology when asked how many years',
    () {
      expect(
        answerer.answer('how many years of flutter experience?'),
        contains('Flutter for 5 years and 2 months'),
      );
    },
  );

  test('should return the computed line when asked for a career fact', () {
    expect(answerer.answer('what was his longest job?'), contains('Initech'));
    expect(answerer.answer('shortest job'), contains('Acme, 2 months'));
    expect(answerer.answer('what was his first job?'), contains('July 2015'));
    expect(answerer.answer('what is his current role?'), contains('Lead'));
    expect(answerer.answer('any career gaps?'), contains('Job changes: 3'));
    expect(answerer.answer('has he led a team?'), contains('Tech Lead'));
    expect(answerer.answer('how many companies?'), contains('7 different'));
    expect(
      answerer.answer('how many languages can he speak?'),
      contains('Spoken languages (2)'),
    );
  });

  test('should leave the question to the model when it names a place', () {
    expect(answerer.answer('longest job at Initech'), isNull);
  });
}
