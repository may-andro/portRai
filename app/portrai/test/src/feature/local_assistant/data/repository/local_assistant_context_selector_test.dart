import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_context_selector.dart';
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
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(jsonEncode(context)),
      'Tell me how long was experience in company Stuart?',
    );

    expect(selected, contains('Stuart'));
    expect(selected, contains('startDate: 2022-07-01'));
    expect(selected, contains('endDate: 2024-03-31'));
    expect(
      utf8.encode(selected).length,
      lessThanOrEqualTo(LocalAssistantContextSelector.maxContextBytes),
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

      final selected = LocalAssistantContextSelector().select(
        _portfolioOf(context),
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
      final selector = LocalAssistantContextSelector();

      final shortest = selector.select(
        _portfolioOf(context),
        'Tell me shortest company experience?',
      );
      final lines = shortest.split('\n');

      expect(lines[1], contains('4 roles at 4 different companies'));
      expect(lines[2], startsWith('Total professional experience: '));
      expect(
        lines[3],
        'Shortest role: Wahl Analytics (Senior Flutter Developer), '
        'January 2025 to March 2025, 2 months.',
      );
      expect(lines[4], startsWith('Longest role: MediaMarkt Saturn'));
      expect(
        shortest,
        contains(
          'Aayuv (Android Developer), August 2016 to '
          'July 2017, 1 year',
        ),
      );
      expect(
        selector.select(_portfolioOf(context), 'and in 2017?'),
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
        selector.select(_portfolioOf(context), 'how long in India?'),
        contains('India: 1 year (Aayuv)'),
      );
      expect(
        selector.select(_portfolioOf(context), 'What is his email?'),
        isNot(contains('All roles in chronological order')),
      );
    },
  );

  test('should search every section when selecting portfolio facts', () async {
    final portfolio = createPortfolioEntity();
    final getPortfolio = MockGetPortfolioUseCase()
      ..stubCall(Right<GetPortfolioFailure, PortfolioEntity>(portfolio));
    final context = (await GetAssistantContextUseCase(getPortfolio)()).right;
    final selector = LocalAssistantContextSelector();

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
      expect(
        selector.select(_portfolioOf(context), question),
        contains(expected),
      );
    }
  });

  test('should retain the company when a follow-up omits its name', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
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
      ),
      'What were his achievements there?',
      previousQuestion: 'How long did he work at Stuart?',
    );

    expect(selected.indexOf('Stuart'), lessThan(selected.indexOf('Other')));
    expect(selected, contains('Modularized the app'));
  });

  test(
    'should respect the byte budget when the portfolio contains long text',
    () {
      final selected = LocalAssistantContextSelector().select(
        _portfolioOf(
          jsonEncode({
            'profile': {'detailedBio': List.filled(20000, 'é').join()},
          }),
        ),
        'Tell me about his background',
      );

      expect(
        utf8.encode(selected).length,
        lessThanOrEqualTo(LocalAssistantContextSelector.maxContextBytes),
      );
    },
  );

  test('should rank the project links first when asked for a store link', () {
    final context = jsonEncode({
      'projects': [
        {
          'title': 'Other',
          'links': [
            'Links for the Other project in Spain: Play Store link: not found.',
          ],
        },
        {
          'title': 'Stuart',
          'links': [
            'Links for the Stuart project in Spain: Play Store link: https://p/stuart.',
          ],
        },
      ],
    });

    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(context),
      'give me playstore link for stuart',
      maxBytes: 200,
    );

    expect(selected, contains('https://p/stuart'));
  });

  test('should rank the resume link before project links when asked', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'profile': {
            'resume': {'url': 'https://r/cv.pdf', 'lastUpdated': '2025-10-15'},
          },
          'projects': [
            {
              'title': 'Other',
              'links': [
                'Links for the Other project in Spain: Play Store link: https://p/other.',
              ],
            },
          ],
        }),
      ),
      'Give me the resume link',
    );

    expect(
      selected.indexOf('https://r/cv.pdf'),
      lessThan(selected.indexOf('https://p/other')),
    );
  });

  test('should skip null values and presentation fields', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'experiences': [
            {
              'company': 'Stuart',
              'endDate': null,
              'companyLogo': 'https://logo',
              'id': 'stuart',
              'latitude': 1.5,
              'description': 'Delivery platform',
            },
          ],
        }),
      ),
      'Tell me about Stuart',
    );

    expect(selected, contains('Delivery platform'));
    expect(selected, isNot(contains('not provided')));
    expect(selected, isNot(contains('endDate')));
    expect(selected, isNot(contains('https://logo')));
    expect(selected, isNot(contains('latitude')));
    expect(selected, isNot(contains('.id:')));
  });

  test('should keep a record of plain values on one line', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'expertises': [
            {
              'title': 'Backend',
              'skills': [
                {'name': 'GraphQL', 'level': 'advanced', 'years': 5},
              ],
            },
          ],
        }),
      ),
      'What is his level in GraphQL?',
    );

    expect(
      selected.split('\n')[1],
      'expertises[0] (Backend).skills[0]: name: GraphQL, level: advanced, '
      'years: 5',
    );
  });

  test('should state that an empty list has nothing listed', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'profile': {'certifications': <String>[]},
          'digest': ['Project X'],
        }),
      ),
      'Does he have any certifications?',
    );

    expect(selected.split('\n')[1], 'profile.certifications: none listed');
  });

  test('should rank a named section before the digest', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'digest': ['Project X'],
          'testimonials': [
            {'name': 'Pitter Wahl', 'testimonial': 'Great work'},
          ],
        }),
      ),
      'What did the testimonials say?',
    );

    expect(
      selected.indexOf('Great work'),
      lessThan(selected.indexOf('Project X')),
    );
  });

  test('should not treat an everyday service title as a name', () {
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'digest': ['Project MediaMarkt: On Play Store: yes.'],
          'services': [
            {'title': 'Intelligent Apps', 'detail': 'AI agents'},
          ],
        }),
      ),
      'Which apps are on the Play Store?',
    );

    expect(
      selected.indexOf('Project MediaMarkt'),
      lessThan(selected.indexOf('AI agents')),
    );
  });

  test('should split long text at sentence ends', () {
    final sentence = 'Built ${'x' * 120} feature.';
    final selected = LocalAssistantContextSelector().select(
      _portfolioOf(
        jsonEncode({
          'projects': [
            {
              'title': 'Stuart',
              'description': List.filled(5, sentence).join(' '),
            },
          ],
        }),
      ),
      'Tell me about Stuart',
    );
    final parts = selected
        .split('\n')
        .where((line) => line.contains('.description: '))
        .toList();

    expect(parts, hasLength(3));
    for (final part in parts) {
      expect(part, endsWith('feature.'));
      expect(part.runes.length, lessThanOrEqualTo(340));
    }
  });

  test('should treat a pronoun as a follow-up only when nothing is named', () {
    final portfolio = _portfolioOf(
      jsonEncode({
        'experiences': [
          {
            'company': 'MediaMarkt Saturn',
            'technologies': ['Flutter'],
          },
        ],
        'projects': [
          {'title': 'Stuart'},
        ],
      }),
    );

    expect(
      LocalAssistantContextSelector.isFollowUp(
        portfolio,
        'What were his achievements there?',
      ),
      isTrue,
    );
    expect(
      LocalAssistantContextSelector.isFollowUp(
        portfolio,
        'Is there a GitHub link for Stuart?',
      ),
      isFalse,
    );
    expect(
      LocalAssistantContextSelector.isFollowUp(
        portfolio,
        'What did he build at MediaMarkt with it?',
      ),
      isFalse,
    );
    expect(
      LocalAssistantContextSelector.isFollowUp(
        portfolio,
        'Does he use Flutter?',
      ),
      isFalse,
    );
  });
}

Map<String, dynamic> _portfolioOf(String portfolioContext) =>
    jsonDecode(portfolioContext) as Map<String, dynamic>;
