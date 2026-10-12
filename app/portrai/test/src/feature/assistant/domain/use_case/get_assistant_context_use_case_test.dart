import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/get_assistant_context_use_case.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';

void main() {
  group('GetAssistantContextUseCase', () {
    test(
      'should build context from portfolio content when loading succeeds',
      () async {
        final portfolio = createPortfolioEntity();
        final getPortfolioUseCase = MockGetPortfolioUseCase()
          ..stubCall(Right<GetPortfolioFailure, PortfolioEntity>(portfolio));
        final useCase = GetAssistantContextUseCase(getPortfolioUseCase);

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, contains(portfolio.profile.fullName));
        expect(result.right, contains(portfolio.profile.email));
        expect(result.right, contains(portfolio.profile.phone));
        expect(result.right, contains(portfolio.profile.socialLinks.first.url));
        expect(result.right, contains(portfolio.projects.first.title));
        expect(result.right, contains(portfolio.experiences.first.company));
        expect(
          result.right,
          contains(portfolio.expertises.first.skills.first.name),
        );
        expect(result.right, contains(portfolio.services.first.title));
        final context = jsonDecode(result.right) as Map<String, Object?>;
        final profile = context['profile']! as Map<String, Object?>;
        final hours = profile['workingHours']! as Map<String, Object?>;
        final resume = profile['resume']! as Map<String, Object?>;
        final availability = profile['availability']! as Map<String, Object?>;
        final digest = (context['digest']! as List).cast<String>();
        expect(
          digest.where((line) => line.startsWith('Project ')).length,
          portfolio.projects.length,
        );
        expect(
          digest.any(
            (line) => line.contains(portfolio.experiences.first.company),
          ),
          isTrue,
        );
        expect(profile['educations'], isNotEmpty);
        expect(profile['languages'], isNotEmpty);
        expect(
          hours['preferredHours'],
          portfolio.profile.workingHours.preferredHours,
        );
        expect(resume['url'], portfolio.profile.resume.url);
        expect(
          availability['hourlyRate'],
          portfolio.profile.availability.hourlyRate,
        );
        expect(
          _firstRecord(context, 'testimonials')['testimonial'],
          portfolio.testimonials.first.testimonial,
        );
        expect(
          _firstRecord(context, 'projects')['longDescription'],
          portfolio.projects.first.longDescription,
        );
        expect(
          _firstRecord(context, 'projects')['features'],
          portfolio.projects.first.features,
        );
        expect(
          _firstRecord(context, 'services')['detail'],
          portfolio.services.first.detail,
        );
        expect(
          _firstRecord(context, 'experiences')['responsibilities'],
          portfolio.experiences.first.responsibilities,
        );
        expect(
          _firstRecord(context, 'experiences')['achievements'],
          portfolio.experiences.first.achievements,
        );
      },
    );

    test(
      'should write out store links and mark missing ones as not found',
      () async {
        final getPortfolioUseCase = MockGetPortfolioUseCase()
          ..stubCall(
            Right<GetPortfolioFailure, PortfolioEntity>(
              createPortfolioEntity(
                projects: [
                  createProjectEntity(
                    title: 'Stuart',
                    playStore: 'https://play.google.com/stuart',
                    appStore: null,
                  ),
                ],
              ),
            ),
          );

        final result = await GetAssistantContextUseCase(getPortfolioUseCase)();

        final summary = _firstRecord(
          jsonDecode(result.right) as Map<String, Object?>,
          'projects',
        )['summary'];
        expect(
          summary,
          contains('Play Store link: https://play.google.com/stuart'),
        );
        expect(summary, contains('App Store link: not found'));
      },
    );

    test(
      'should write each project market with its coordinates and store links',
      () async {
        final getPortfolio = MockGetPortfolioUseCase()
          ..stubCall(
            Right<GetPortfolioFailure, PortfolioEntity>(
              createPortfolioEntity(
                projects: [
                  createProjectEntity(
                    markets: const [
                      ProjectMarketEntity(
                        country: 'Germany',
                        latitude: 51.1657,
                        longitude: 10.4515,
                        playStore: 'https://play.google.com/de',
                      ),
                    ],
                  ),
                  createProjectEntity(id: 'other'),
                ],
              ),
            ),
          );

        final result = await GetAssistantContextUseCase(getPortfolio)();

        final projects =
            (jsonDecode(result.right) as Map<String, Object?>)['projects']!
                as List<Object?>;
        final first = projects.first! as Map<String, Object?>;
        final market = (first['markets']! as List).single as Map;
        expect(market['country'], 'Germany');
        expect(market['latitude'], 51.1657);
        expect(first['summary'], contains('Germany: Play Store link'));
        expect((projects.last! as Map).containsKey('markets'), isFalse);
      },
    );

    test(
      'should link projects and testimonials to their experience when ids match',
      () async {
        final experience = ExperienceEntity(
          company: 'Stuart',
          position: 'Senior Flutter Developer',
          location: 'Barcelona',
          startDate: DateTime(2022, 7),
          endDate: null,
          current: true,
          employmentType: 'Full-time',
          description: 'Delivery platform',
          longDescription: 'Built the delivery platform',
          responsibilities: const [],
          achievements: const [],
          technologies: const ['Flutter'],
          companyLogo: '',
          url: null,
          id: 'stuart',
        );
        final getPortfolio = MockGetPortfolioUseCase()
          ..stubCall(
            Right<GetPortfolioFailure, PortfolioEntity>(
              createPortfolioEntity(
                experiences: [experience],
                projects: [
                  createProjectEntity(id: 'p1', experienceId: 'stuart'),
                  createProjectEntity(id: 'p2', experienceId: 'unknown'),
                ],
                testimonials: [createTestimonialEntity(experienceId: 'stuart')],
              ),
            ),
          );

        final result = await GetAssistantContextUseCase(getPortfolio)();
        final context = jsonDecode(result.right) as Map<String, Object?>;
        final projects = (context['projects']! as List)
            .cast<Map<String, Object?>>();
        final reference = {
          'company': 'Stuart',
          'position': 'Senior Flutter Developer',
        };

        expect(projects.first['experienceId'], 'stuart');
        expect(projects.first['experience'], reference);
        expect(projects.last.containsKey('experience'), isFalse);
        expect(_firstRecord(context, 'testimonials')['experience'], reference);
        expect(_firstRecord(context, 'experiences')['projects'], [
          {'id': 'p1', 'title': 'PortRai 🚀'},
        ]);
      },
    );

    test(
      'should write skill levels and the project a testimonial refers to',
      () async {
        final getPortfolio = MockGetPortfolioUseCase()
          ..stubCall(
            Right<GetPortfolioFailure, PortfolioEntity>(
              createPortfolioEntity(
                expertises: const [
                  ExpertiseEntity(
                    image: 'flutter.png',
                    title: 'Flutter',
                    skills: [
                      SkillEntity(
                        name: 'Dart',
                        level: 'expert',
                        years: 7,
                        lastUsed: 2026,
                      ),
                      SkillEntity(name: 'Bloc'),
                    ],
                  ),
                ],
                projects: [createProjectEntity(id: 'p1')],
                testimonials: [createTestimonialEntity(projectId: 'p1')],
              ),
            ),
          );

        final result = await GetAssistantContextUseCase(getPortfolio)();
        final context = jsonDecode(result.right) as Map<String, Object?>;

        expect(_firstRecord(context, 'expertises')['skills'], [
          {'name': 'Dart', 'level': 'expert', 'years': 7, 'lastUsed': 2026},
          {'name': 'Bloc'},
        ]);
        expect(_firstRecord(context, 'testimonials')['project'], 'PortRai 🚀');
      },
    );

    test(
      'should include dates and duration when employment has ended',
      () async {
        final experience = ExperienceEntity(
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
              createPortfolioEntity(experiences: [experience]),
            ),
          );

        final result = await GetAssistantContextUseCase(getPortfolio)();
        final context = jsonDecode(result.right) as Map<String, Object?>;
        final employment = _firstRecord(context, 'experiences');

        expect(employment['company'], 'Stuart');
        expect(employment['startDate'], '2022-07-01');
        expect(employment['endDate'], '2024-03-31');
        expect(employment['current'], false);
        expect(
          employment['summary'],
          'Worked as Senior Flutter Developer at Stuart from July 2022 to '
          'March 2024. Total time at Stuart: 1 year and 9 months.',
        );
      },
    );

    test(
      'should return an assistant failure when portfolio loading fails',
      () async {
        final getPortfolioUseCase = MockGetPortfolioUseCase()
          ..stubCall(
            const Left<GetPortfolioFailure, PortfolioEntity>(
              GetPortfolioNotFoundFailure(),
            ),
          );
        final useCase = GetAssistantContextUseCase(getPortfolioUseCase);

        final result = await useCase();

        expect(result.left, isA<UnknownAssistantFailure>());
        expect(result.left.cause, isA<GetPortfolioNotFoundFailure>());
      },
    );
  });
}

Map<String, Object?> _firstRecord(
  Map<String, Object?> context,
  String section,
) => (context[section]! as List<Object?>).first! as Map<String, Object?>;
