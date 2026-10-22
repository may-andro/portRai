import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_direct_answerer.dart';

Map<String, dynamic> _portfolio({Map<String, Object?>? profile}) =>
    jsonDecode(
          jsonEncode({
            'profile':
                profile ??
                {
                  'name': 'Mayank Rai',
                  'email': 'm@x.com',
                  'phone': '123',
                  'socialLinks': [
                    {'name': 'LinkedIn', 'url': 'https://l/in'},
                    {'name': 'Github', 'url': 'https://g/h'},
                  ],
                },
            'experiences': [
              {
                'company': 'Initech',
                'technologies': ['Flutter'],
              },
              {'company': 'Acme'},
            ],
            'projects': [
              {
                'title': 'Stuart',
                'technologies': ['Flutter', 'Flutter Web'],
                'markets': [
                  {'country': 'Spain', 'playStore': 'https://p/stuart'},
                ],
              },
              {
                'title': 'Tote',
                'technologies': ['Kotlin', 'Flutter'],
                'markets': [
                  {'country': 'US', 'playStore': '', 'website': 'https://w'},
                ],
              },
            ],
            'services': [
              {'title': 'App Development', 'description': 'Mobile apps.'},
              {'title': 'Consulting'},
            ],
            'overview': [
              'Total time worked per country, overlapping roles counted once: Spain: 6 years and 10 months (A, B); India: 4 years (C, D).',
              'Career overview: 8 roles at 7 different companies.',
              'Total professional experience: 9 years (July 2015 to present), overlapping roles counted once.',
              'Longest role: Initech, 2 years.',
              'Shortest role: Acme, 2 months.',
              'First role (earliest start): Acme, July 2015.',
              'Current role: Lead at Initech since April 2024.',
              'Time per company, overlapping roles counted once: Initech: 2 years in 1 role (Lead, April 2024 to present). Acme: 2 years and 2 months in 2 roles (Dev, July 2015 to September 2015; Senior Dev, January 2016 to February 2018).',
              'Time using each technology across all roles, overlapping roles counted once (technologies listed on the roles): Flutter: 5 years and 2 months; Android: 4 years; Android SDK: 6 years.',
              'Career gaps: none, there is no month without a role. Job changes: 3.',
              'Leadership roles: Tech Lead at Initech.',
              'All roles in chronological order, to answer questions about a year or period: Acme (Dev), July 2015 to September 2015, 3 months, located in India; Initech (Lead), April 2024 to present, 2 years, located in Spain.',
              'Spoken languages (2): English (Fluent), Spanish (Proficient). No other spoken languages are listed.',
              'Experience per city, with time worked and roles: Hyderabad: 2 years and 11 months in 2 roles (C (Dev), D (Lead)); Pune: 2 years and 1 month in 1 role (E (Junior)).',
            ],
          }),
        )
        as Map<String, dynamic>;

void main() {
  final answerer = LocalAssistantDirectAnswerer(_portfolio());

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

  test('should return the social link when the question names the network', () {
    expect(
      answerer.answer('How can I contact him on LinkedIn?'),
      "Mayank Rai's LinkedIn: https://l/in",
    );
    expect(answerer.answer('what is his github?'), contains('https://g/h'));
  });

  test('should leave a product question to the model when it says contact', () {
    expect(answerer.answer('Did he build a contact app?'), isNull);
    expect(answerer.answer('Is there a GitHub link for Stuart?'), isNull);
  });

  test('should leave a count to the model when the question says number', () {
    expect(
      answerer.answer('What is the number of projects he delivered?'),
      isNull,
    );
  });

  test('should skip a contact detail that the portfolio does not list', () {
    final emailOnly = LocalAssistantDirectAnswerer(
      _portfolio(profile: {'name': 'Mayank Rai', 'email': 'm@x.com'}),
    );
    expect(emailOnly.answer('phone number?'), isNull);
    expect(
      emailOnly.answer('How can I reach him?'),
      'You can contact Mayank Rai by email at m@x.com.',
    );
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

  test('should state the company tenure when asked how long at a company', () {
    expect(
      answerer.answer('How long did he work at Initech?'),
      'Mayank Rai worked at Initech for 2 years as Lead, April 2024 to '
      'present.',
    );
    expect(
      answerer.answer('how many years was he at acme?'),
      'Mayank Rai worked at Acme for 2 years and 2 months across 2 roles: '
      'Dev, July 2015 to September 2015; Senior Dev, January 2016 to '
      'February 2018.',
    );
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

  test('should prefer the longer technology name when both match', () {
    expect(
      answerer.answer('how many years of android sdk experience?'),
      contains('Android SDK for 6 years'),
    );
    expect(
      answerer.answer('how long has he used android?'),
      contains('Android for 4 years'),
    );
  });

  test('should state the total experience when nothing specific is named', () {
    expect(
      answerer.answer('How many years of experience does he have?'),
      'Mayank Rai has 9 years of professional experience (July 2015 to '
      'present), counting overlapping roles once.',
    );
    expect(
      answerer.answer('How many years of experience does he have in Spain?'),
      contains('in Spain'),
    );
  });

  test('should return the computed line when asked for a career fact', () {
    expect(
      answerer.answer('what was his longest job?'),
      "Mayank Rai's longest role: Initech, 2 years.",
    );
    expect(answerer.answer('shortest job'), contains('Acme, 2 months'));
    expect(answerer.answer('what was his first job?'), contains('July 2015'));
    expect(answerer.answer('what is his current role?'), contains('Lead'));
    expect(
      answerer.answer('Who is his current employer?'),
      contains('Lead at Initech'),
    );
    expect(
      answerer.answer('Where is he working now?'),
      contains('Lead at Initech'),
    );
    expect(answerer.answer('any career gaps?'), contains('Job changes: 3'));
    expect(answerer.answer('has he led a team?'), contains('Tech Lead'));
    expect(answerer.answer('how many companies?'), contains('7 different'));
    expect(
      answerer.answer('how many languages can he speak?'),
      'Mayank Rai speaks 2 languages: English (Fluent), Spanish (Proficient).',
    );
  });

  test('should leave the question to the model when it names a place', () {
    expect(answerer.answer('longest job at Initech'), isNull);
  });

  test('should list the projects in a store when asked', () {
    expect(
      answerer.answer('Which apps are on the Play Store?'),
      "Mayank Rai's projects on the Play Store: Stuart.",
    );
    expect(
      answerer.answer('Which projects have a website?'),
      "Mayank Rai's projects with a website: Tote.",
    );
    expect(
      answerer.answer('Which apps are on the App Store?'),
      'No project in the portfolio is listed on the App Store.',
    );
  });

  test('should list the projects using a technology when asked', () {
    expect(
      answerer.answer('Which projects use Flutter?'),
      "Mayank Rai's projects that use Flutter: Stuart, Tote.",
    );
    expect(
      answerer.answer('Which apps were built with Flutter Web?'),
      "Mayank Rai's projects that use Flutter Web: Stuart.",
    );
  });

  test('should leave project questions about a named record to the model', () {
    expect(answerer.answer('Which Flutter apps did he build at Acme?'), isNull);
    expect(answerer.answer('Is Stuart on the Play Store?'), isNull);
  });

  test('should list the services when asked', () {
    expect(
      answerer.answer('Which services are offered?'),
      'Mayank Rai offers these services:\n'
      '- App Development: Mobile apps.\n'
      '- Consulting',
    );
  });

  test('should summarize the experience from the overview', () {
    expect(
      answerer.answer('Summarize the experience'),
      'Mayank Rai has 9 years of professional experience (July 2015 to '
      'present), counting overlapping roles once.\n'
      'In total: 8 roles at 7 different companies.\n'
      'Current role: Lead at Initech since April 2024.\n'
      'Roles from the most recent:\n'
      '- Initech (Lead), April 2024 to present, 2 years\n'
      '- Acme (Dev), July 2015 to September 2015, 3 months',
    );
  });

  test('should leave an earlier employer to the model', () {
    expect(answerer.answer('Who was his previous employer?'), isNull);
    expect(answerer.answer('Which employer came before that?'), isNull);
  });

  test('should leave a longest project to the model', () {
    expect(answerer.answer('What was his longest project?'), isNull);
  });

  test('should leave programming languages to the model', () {
    expect(
      answerer.answer('How many programming languages does he know?'),
      isNull,
    );
  });

  test('should leave management of releases to the model', () {
    expect(answerer.answer('Has he managed app releases?'), isNull);
  });

  test('should leave leadership at a named company to the model', () {
    expect(answerer.answer('Which team did he lead at Initech?'), isNull);
  });
}
