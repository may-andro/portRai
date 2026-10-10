import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_context_selector.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/get_assistant_context_use_case.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

void main() {
  test('should select Stuart dates when asked about company tenure', () {
    // Self-contained: the dashboard assets are gitignored and absent in CI.
    final context = <String, Object?>{
      'profile': {'name': 'Mayank Rai', 'summary': 'x' * 3000},
      'projects': [
        for (var i = 0; i < 20; i++)
          {'title': 'Project $i', 'description': 'y' * 400},
      ],
      'experiences': [
        {
          'company': 'Stuart',
          'position': 'Senior Flutter Developer',
          'startDate': '2022-07-01',
          'endDate': '2024-03-31',
          'description': 'z' * 400,
        },
        for (var i = 0; i < 6; i++)
          {'company': 'Other $i', 'description': 'w' * 400},
      ],
    };
    final selected = AssistantContextSelector().select(
      jsonEncode(context),
      'Tell me how long was experience in company Stuart?',
    );

    expect(selected, contains('Stuart'));
    expect(selected, contains('startDate: 2022-07-01'));
    expect(selected, contains('endDate: 2024-03-31'));
    expect(
      utf8.encode(selected).length,
      lessThanOrEqualTo(AssistantContextSelector.maxContextBytes),
    );
  });

  test(
    'should rank the ready-written duration first when asked how long',
    () async {
      final stuart = ExperienceEntity(
        company: 'Stuart',
        position: 'Senior Flutter Developer',
        location: 'Barcelona',
        startDate: DateTime(2022, 7),
        endDate: DateTime(2024, 3, 31),
        current: false,
        employmentType: 'Full-time',
        description: 'Delivery platform',
        longDescription: 'Built the delivery platform',
        responsibilities: const ['Design system'],
        achievements: const ['Modularized the app'],
        technologies: const ['Flutter'],
        companyLogo: '',
        url: null,
        id: 'stuart',
      );
      final getPortfolio = MockGetPortfolioUseCase()
        ..stubCall(
          Right<GetPortfolioFailure, PortfolioEntity>(
            createPortfolioEntity(experiences: [stuart]),
          ),
        );
      final context = (await GetAssistantContextUseCase(getPortfolio)()).right;

      final selected = AssistantContextSelector().select(
        context,
        'How long was stuart experience?',
      );

      expect(
        selected.split('\n')[1],
        'Worked as Senior Flutter Developer at Stuart from July 2022 to '
        'March 2024. Total time at Stuart: 1 year and 9 months.',
      );
    },
  );

  test(
    'should state the shortest and longest roles when asked to compare',
    () async {
      ExperienceEntity role(
        String company,
        String position,
        DateTime start,
        DateTime? end,
      ) => ExperienceEntity(
        company: company,
        position: position,
        location: company == 'Aayuv' ? 'Hyderabad, India [Remote]' : 'Spain',
        startDate: start,
        endDate: end,
        current: end == null,
        employmentType: 'Full-time',
        description: 'd',
        longDescription: 'l',
        responsibilities: const [],
        achievements: const [],
        technologies: const [],
        companyLogo: '',
        url: null,
        id: company,
      );
      final getPortfolio = MockGetPortfolioUseCase()
        ..stubCall(
          Right<GetPortfolioFailure, PortfolioEntity>(
            createPortfolioEntity(
              experiences: [
                role(
                  'Wahl Analytics',
                  'Senior Flutter Developer',
                  DateTime(2025),
                  DateTime(2025, 3),
                ),
                role(
                  'Stuart',
                  'Senior Flutter Developer',
                  DateTime(2022, 7),
                  DateTime(2024, 3, 31),
                ),
                role(
                  'Aayuv',
                  'Android Developer',
                  DateTime(2016, 8),
                  DateTime(2017, 7, 31),
                ),
                role('MediaMarkt Saturn', 'Tech Lead', DateTime(2024, 4), null),
              ],
            ),
          ),
        );
      final context = (await GetAssistantContextUseCase(getPortfolio)()).right;
      final selector = AssistantContextSelector();

      final shortest = selector.select(
        context,
        'Tell me shortest company experience?',
      );
      final lines = shortest.split('\n');

      expect(lines[1], contains('4 roles at 4 different companies'));
      expect(
        lines[2],
        'Shortest role: Wahl Analytics (Senior Flutter Developer), '
        'January 2025 to March 2025, 2 months.',
      );
      expect(lines[3], startsWith('Longest role: MediaMarkt Saturn'));
      expect(
        shortest,
        contains(
          'Aayuv (Android Developer), August 2016 to '
          'July 2017, 1 year',
        ),
      );
      expect(
        selector.select(context, 'and in 2017?'),
        contains('chronological order'),
      );
      expect(
        shortest,
        contains(
          'chronological order, to answer questions about a year or period: '
          'Aayuv (Android Developer), August 2016 to July 2017, 1 year, '
          'located in India; ',
        ),
      );
      expect(
        selector.select(context, 'how long in India?'),
        contains('India: 1 year (Aayuv)'),
      );
      expect(
        selector.select(context, 'What is his email?'),
        isNot(contains('All roles in chronological order')),
      );
    },
  );

  test('should search every section when selecting portfolio facts', () async {
    final portfolio = createPortfolioEntity();
    final getPortfolio = MockGetPortfolioUseCase()
      ..stubCall(Right<GetPortfolioFailure, PortfolioEntity>(portfolio));
    final context = (await GetAssistantContextUseCase(getPortfolio)()).right;
    final selector = AssistantContextSelector();

    for (final (question, expected) in [
      (
        'What education does Mayank have?',
        portfolio.profile.educations.first.degree,
      ),
      (
        'What languages does he speak?',
        portfolio.profile.languages.first.proficiency,
      ),
      ('What is his hourly rate?', portfolio.profile.availability.hourlyRate),
      ('Where can I download the resume?', portfolio.profile.resume.url),
      ('What do testimonials say?', portfolio.testimonials.first.testimonial),
      ('Tell me about Consulting', portfolio.services.first.detail),
    ]) {
      expect(selector.select(context, question), contains(expected));
    }
  });

  test('should retain the company when a follow-up omits its name', () {
    final selected = AssistantContextSelector().select(
      jsonEncode({
        'experiences': [
          {
            'company': 'Stuart',
            'achievements': ['Modularized the app'],
          },
          {
            'company': 'Other',
            'achievements': ['Another launch'],
          },
        ],
      }),
      'What were his achievements there?',
      previousQuestion: 'How long did he work at Stuart?',
    );

    expect(selected.indexOf('Stuart'), lessThan(selected.indexOf('Other')));
    expect(selected, contains('Modularized the app'));
  });

  test(
    'should respect the byte budget when the portfolio contains long text',
    () {
      final selected = AssistantContextSelector().select(
        jsonEncode({
          'profile': {'detailedBio': List.filled(20000, 'é').join()},
        }),
        'Tell me about his background',
      );

      expect(
        utf8.encode(selected).length,
        lessThanOrEqualTo(AssistantContextSelector.maxContextBytes),
      );
    },
  );

  test('should rank the project links first when asked for a store link', () {
    final context = jsonEncode({
      'projects': [
        {
          'title': 'Other',
          'summary': 'Links for the Other project. Play Store link: not found.',
        },
        {
          'title': 'Stuart',
          'summary':
              'Links for the Stuart project. Play Store link: https://p/stuart.',
        },
      ],
    });

    final selected = AssistantContextSelector().select(
      context,
      'give me playstore link for stuart',
      maxBytes: 200,
    );

    expect(selected, contains('https://p/stuart'));
  });
}
