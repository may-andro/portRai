import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/get_assistant_context_use_case.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

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
        expect(result.right, contains(portfolio.expertises.first.skills.first));
        expect(result.right, contains(portfolio.services.first.title));
        final context = jsonDecode(result.right) as Map<String, Object?>;
        final profile = context['profile']! as Map<String, Object?>;
        final hours = profile['workingHours']! as Map<String, Object?>;
        final resume = profile['resume']! as Map<String, Object?>;
        final availability = profile['availability']! as Map<String, Object?>;
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
