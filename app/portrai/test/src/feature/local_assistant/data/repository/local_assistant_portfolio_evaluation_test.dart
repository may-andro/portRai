import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/experience/data/mapper/experience_mapper.dart';
import 'package:portrai/src/feature/experience/data/model/experience_model.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_context_selector.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_direct_answerer.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/profile/data/mapper/availability_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/certification_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/coordinates_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/education_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/language_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/location_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/profile_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/published_at_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/resume_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/social_link_mapper.dart';
import 'package:portrai/src/feature/profile/data/mapper/working_hours_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/profile_model.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/data/model/project_model.dart';
import 'package:portrai/src/feature/service/data/mapper/service_mapper.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';
import 'package:portrai/src/feature/testimonial/data/mapper/testimonial_mapper.dart';
import 'package:portrai/src/feature/testimonial/data/model/testimonial_model.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';

// Runs the assistant over the real portfolio in assets/dashboard. Those files
// are git-ignored, so the test is skipped where they are absent, such as CI.
// The portfolio is parsed with each feature's own models and mappers, the
// same path the app's asset repositories take.
// It checks which questions are answered directly and what the model would
// see first, which the hand-built fixtures elsewhere cannot catch.
const _dashboard = 'assets/dashboard';

final _skip = File('$_dashboard/profile.json').existsSync()
    ? false
    : 'The portfolio data in $_dashboard is not present.';

Map<String, dynamic> _section(String file) =>
    (jsonDecode(File('$_dashboard/$file.json').readAsStringSync())
            as Map<String, dynamic>)['en']
        as Map<String, dynamic>;

List<Map<String, dynamic>> _records(String file, String key) => [
  for (final record in _section(file)[key] as List)
    {...record as Map<String, dynamic>, 'locale': 'en'},
];

PortfolioEntity _loadPortfolio() {
  final locale = AppLocale('en');
  final profileJson = {
    ...(_section('profile')['profile'] as Map<String, dynamic>),
    'locale': 'en',
  };
  return PortfolioEntity(
    profile: ProfileMapper(
      publishedAtMapper: const PublishedAtMapper(),
      resumeMapper: const ResumeMapper(),
      socialLinkMapper: const SocialLinkMapper(),
      availabilityMapper: const AvailabilityMapper(),
      workingHoursMapper: const WorkingHoursMapper(),
      locationMapper: const LocationMapper(
        coordinatesMapper: CoordinatesMapper(),
      ),
      languageMapper: const LanguageMapper(),
      educationMapper: const EducationMapper(),
      certificationMapper: const CertificationMapper(),
      appLocale: locale,
    ).to(ProfileModel.fromJson(profileJson)),
    expertises: [
      for (final json in _records('expertise', 'experties'))
        ExpertiseMapper(appLocale: locale).to(ExpertiseModel.fromJson(json)),
    ],
    projects: [
      for (final json in _records('projects', 'projects'))
        ProjectMapper(appLocale: locale).to(ProjectModel.fromJson(json)),
    ],
    services: [
      for (final json in _records('services', 'services'))
        ServiceMapper(appLocale: locale).to(ServiceModel.fromJson(json)),
    ],
    experiences: [
      for (final json in _records('experiences', 'experiences'))
        ExperienceMapper(appLocale: locale).to(ExperienceModel.fromJson(json)),
    ],
    testimonials: [
      for (final json in _records('testimonials', 'testimonials'))
        TestimonialMapper(
          appLocale: locale,
        ).to(TestimonialModel.fromJson(json)),
    ],
  );
}

void main() {
  late PortfolioEntity portfolio;
  late Map<String, dynamic> context;

  setUpAll(() async {
    if (_skip != false) return;
    portfolio = _loadPortfolio();
    final getPortfolio = MockGetPortfolioUseCase()
      ..stubCall(Right<GetPortfolioFailure, PortfolioEntity>(portfolio));
    context =
        jsonDecode((await GetAssistantContextUseCase(getPortfolio)()).right)
            as Map<String, dynamic>;
  });

  String? directAnswer(String question) =>
      LocalAssistantDirectAnswerer(context).answer(question);

  List<String> selectedFacts(String question) => LocalAssistantContextSelector()
      .select(context, question)
      .split('\n')
      .skip(1)
      .toList();

  group('portfolio evaluation', skip: _skip, () {
    test('should answer directly when the fact is computed', () {
      final profile = portfolio.profile;
      final expected = <String, String>{
        'What is his email?': profile.email,
        'How can I contact him on LinkedIn?': 'linkedin',
        'Who is his current employer?': profile.currentCompany,
        'How many years of experience does he have?': 'professional experience',
        'How long did he work at ${portfolio.experiences.last.company}?':
            portfolio.experiences.last.company,
        'Which projects use Flutter?': 'projects that use Flutter',
        'Which apps are on the Play Store?': 'on the Play Store',
        'Which services are offered?': portfolio.services.first.title,
        'Summarize the experience': 'Roles from the most recent',
        'What languages does he speak?': profile.languages.first.language,
        'Hi': 'Ask me about',
        'What is his salary?': 'does not list a salary',
      };

      for (final MapEntry(key: question, value: fact) in expected.entries) {
        expect(
          directAnswer(question)?.toLowerCase(),
          contains(fact.toLowerCase()),
          reason: question,
        );
      }
    });

    test('should leave the question to the model when it needs reading', () {
      for (final question in [
        'Did he build a contact app?',
        'What is the number of projects he delivered?',
        'How many programming languages does he know?',
        'Has he managed app releases?',
        'Which team did he lead at ${portfolio.experiences.first.company}?',
        'What was his longest project?',
        'Who was his previous employer?',
        'Tell me about ${portfolio.projects.first.title}',
        'What did the testimonials say?',
      ]) {
        expect(directAnswer(question), isNull, reason: question);
      }
    });

    test('should put the asked fact first when the model answers', () {
      final expected = <String, String>{
        'What did the testimonials say?': portfolio
            .testimonials
            .first
            .testimonial
            .substring(0, 30),
        'Give me the resume link': portfolio.profile.resume.url,
        'Does he have any certifications?': 'none listed',
        'What is his level in GraphQL?': 'GraphQL',
        'Where does he live?': portfolio.profile.location.city,
      };

      for (final MapEntry(key: question, value: fact) in expected.entries) {
        expect(
          selectedFacts(question).take(3).join('\n'),
          contains(fact),
          reason: question,
        );
      }
    });

    test('should leave presentation fields out when selecting facts', () {
      for (final question in [
        'Tell me about ${portfolio.projects.first.title}',
        'Summarize the experience',
        'Which projects use Flutter?',
      ]) {
        final facts = selectedFacts(question).join('\n');
        expect(facts, isNot(contains('companyLogo')), reason: question);
        expect(facts, isNot(contains('.image')), reason: question);
        expect(facts, isNot(contains('latitude')), reason: question);
      }
    });
  });
}
