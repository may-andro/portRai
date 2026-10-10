import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_context_selector.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/get_assistant_context_use_case.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

ExperienceEntity _role(
  String company,
  String position,
  String location,
  DateTime start,
  DateTime end,
  List<String> technologies,
) => ExperienceEntity(
  company: company,
  position: position,
  location: location,
  startDate: start,
  endDate: end,
  current: false,
  employmentType: 'Full-time',
  description: 'Worked at $company',
  longDescription: 'Worked at $company on mobile apps',
  responsibilities: const ['Mobile development'],
  achievements: const ['Shipped apps'],
  technologies: technologies,
  companyLogo: '',
  url: null,
  id: company.toLowerCase(),
);

Future<String> _selectFor(String question, {String? previous}) async {
  final getPortfolio = MockGetPortfolioUseCase()
    ..stubCall(
      Right<GetPortfolioFailure, PortfolioEntity>(
        createPortfolioEntity(
          experiences: [
            _role(
              'Acme',
              'Android Developer',
              'Hyderabad, India',
              DateTime(2015, 7),
              DateTime(2017, 6, 30),
              const ['Android', 'Kotlin'],
            ),
            _role(
              'Globex',
              'Senior Android Developer',
              'Alicante, Spain',
              DateTime(2018),
              DateTime(2019, 12, 31),
              const ['Android', 'Kotlin'],
            ),
            _role(
              'Initech',
              'Tech Lead - Flutter Developer',
              'Barcelona, Spain [Remote]',
              DateTime(2020),
              DateTime(2022, 12, 31),
              const ['Flutter', 'Dart'],
            ),
            _role(
              'Hooli',
              'Senior Flutter Developer',
              'Barcelona, Spain [Freelance]',
              DateTime(2023),
              DateTime(2024, 12, 31),
              const ['Flutter', 'Dart'],
            ),
          ],
        ),
      ),
    );
  final context = (await GetAssistantContextUseCase(getPortfolio)()).right;
  return AssistantContextSelector().select(
    context,
    question,
    previousQuestion: previous,
  );
}

void main() {
  const golden = <String, String>{
    'how long did he work in Spain?': 'Spain: 7 years',
    'how long in India?': 'India: 2 years',
    'how many remote roles?': 'Remote: 1 role (Initech',
    'how many freelance roles?': 'Freelance: 1 role (Hooli',
    'which company was he at in 2016?': 'Acme',
    'what was his longest job?': 'Longest role: Initech',
    'what did he studied':
        'Education: Bachelor in Engineering in Electronics & Telecommunication at Army Institute of Technology',
    'where did he studied': 'Army Institute of Technology',
    'first job': 'First role (earliest start): Acme',
    'what was his shortest job?': 'Shortest role: Acme',
    'how many years of Flutter experience?': 'Flutter: 5 years',
    'how many years of Android experience?': 'Android: 4 years',
    'has he got any career gaps?': 'Career gaps between roles: 6 months',
    'does he change jobs often?': 'Job changes: 3',
    'has he led a team?': 'Leadership roles: Tech Lead - Flutter Developer',
    'how many languages can he speak?':
        'Spoken languages (2): English (Fluent), Spanish (Intermediate)',
    'tell me his career summary': 'Career overview: 4 roles at 4 different',
  };

  group('golden questions', () {
    for (final entry in golden.entries) {
      test(
        'should include "${entry.value}" when asked "${entry.key}"',
        () async {
          final selected = await _selectFor(entry.key);

          expect(selected, contains(entry.value));
        },
      );
    }

    test(
      'should answer for the new country when asked a short follow-up',
      () async {
        final selected = await _selectFor(
          'in spain?',
          previous: 'how long in India?',
        );

        expect(selected, contains('Spain: 7 years'));
      },
    );
  });
}
