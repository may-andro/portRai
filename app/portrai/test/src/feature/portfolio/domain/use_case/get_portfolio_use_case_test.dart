import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/experience/domain/use_case/mock_get_experiences_use_case.dart';
import '../../../../../mock/feature/expertise/domain/use_case/mock_get_all_expertise_use_case.dart';
import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../mock/feature/project/domain/use_case/mock_get_projects_use_case.dart';
import '../../../../../mock/feature/service/domain/use_case/mock_get_services_use_case.dart';
import '../../../../../mock/feature/testimonial/domain/use_case/mock_get_testimonials_use_case.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  final portfolio = createPortfolioEntity();

  group('GetPortfolioUseCase', () {
    late MockGetProfileUseCase getProfileUseCase;
    late MockGetAllExpertiseUseCase getAllExpertiseUseCase;
    late MockGetProjectsUseCase getProjectsUseCase;
    late MockGetServicesUseCase getServicesUseCase;
    late MockGetExperiencesUseCase getExperiencesUseCase;
    late MockGetTestimonialsUseCase getTestimonialsUseCase;
    late MockLogReporter logReporter;
    late GetPortfolioUseCase useCase;

    setUp(() {
      getProfileUseCase = MockGetProfileUseCase();
      getAllExpertiseUseCase = MockGetAllExpertiseUseCase();
      getProjectsUseCase = MockGetProjectsUseCase();
      getServicesUseCase = MockGetServicesUseCase();
      getExperiencesUseCase = MockGetExperiencesUseCase();
      getTestimonialsUseCase = MockGetTestimonialsUseCase();
      logReporter = MockLogReporter();
      useCase = GetPortfolioUseCase(
        getProfileUseCase,
        getAllExpertiseUseCase,
        getProjectsUseCase,
        getServicesUseCase,
        getExperiencesUseCase,
        getTestimonialsUseCase,
        logReporter,
      );

      when(
        () => logReporter.debug(
          any(),
          error: any<Object?>(named: 'error'),
          stacktrace: any<StackTrace?>(named: 'stacktrace'),
          tag: any<String?>(named: 'tag'),
        ),
      ).thenReturn(null);
    });

    test(
      'should return the aggregated portfolio when every use case succeeds',
      () async {
        getProfileUseCase.stubCall(
          Right<GetProfileFailure, ProfileEntity>(portfolio.profile),
        );
        getAllExpertiseUseCase.stubCall(
          Right<GetAllExpertiseFailure, List<ExpertiseEntity>>(
            portfolio.expertises,
          ),
        );
        getProjectsUseCase.stubCall(
          Right<GetProjectsFailure, List<ProjectEntity>>(portfolio.projects),
        );
        getServicesUseCase.stubCall(
          Right<GetServicesFailure, List<ServiceEntity>>(portfolio.services),
        );
        getExperiencesUseCase.stubCall(
          Right<GetExperiencesFailure, List<ExperienceEntity>>(
            portfolio.experiences,
          ),
        );
        getTestimonialsUseCase.stubCall(
          Right<GetTestimonialsFailure, List<TestimonialEntity>>(
            portfolio.testimonials,
          ),
        );

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, portfolio);
      },
    );

    test(
      'should return a not found failure when loading the profile fails',
      () async {
        const failure = ProfileNotFoundFailure();
        getProfileUseCase.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(failure),
        );

        final result = await useCase();

        expect(result.left, isA<GetPortfolioNotFoundFailure>());
        expect(result.left.cause, same(failure));
      },
    );

    test(
      'should fallback to empty optional collections when secondary use cases fail',
      () async {
        getProfileUseCase.stubCall(
          Right<GetProfileFailure, ProfileEntity>(portfolio.profile),
        );
        getAllExpertiseUseCase.stubCall(
          const Left<GetAllExpertiseFailure, List<ExpertiseEntity>>(
            ExpertiseUnknownFailure(),
          ),
        );
        getProjectsUseCase.stubCall(
          const Left<GetProjectsFailure, List<ProjectEntity>>(
            ProjectUnknownFailure(),
          ),
        );
        getServicesUseCase.stubCall(
          const Left<GetServicesFailure, List<ServiceEntity>>(
            ServicesUnknownFailure(),
          ),
        );
        getExperiencesUseCase.stubCall(
          const Left<GetExperiencesFailure, List<ExperienceEntity>>(
            ExperiencesUnknownFailure(),
          ),
        );
        getTestimonialsUseCase.stubCall(
          const Left<GetTestimonialsFailure, List<TestimonialEntity>>(
            TestimonialsUnknownFailure(),
          ),
        );

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right.expertises, isEmpty);
        expect(result.right.projects, isEmpty);
        expect(result.right.services, isEmpty);
        expect(result.right.experiences, isEmpty);
        expect(result.right.testimonials, isEmpty);
        verify(
          () => logReporter.debug(
            any(),
            error: any<Object?>(named: 'error'),
            stacktrace: any<StackTrace?>(named: 'stacktrace'),
            tag: 'GetPortfolioUseCase',
          ),
        ).called(5);
      },
    );

    test(
      'should return an unknown failure when a dependency throws unexpectedly',
      () async {
        final error = Exception('boom');
        when(() => getProfileUseCase()).thenThrow(error);

        final result = await useCase();

        expect(result.left, isA<GetPortfolioUnknownFailure>());
        expect(result.left.cause, same(error));
      },
    );
  });
}
