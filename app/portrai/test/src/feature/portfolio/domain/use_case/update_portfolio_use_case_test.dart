import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/experience/domain/use_case/mock_refresh_experiences_use_case.dart';
import '../../../../../mock/feature/expertise/domain/use_case/mock_refresh_all_expertise_use_case.dart';
import '../../../../../mock/feature/portfolio/domain/repository/mock_portfolio_update_repository.dart';
import '../../../../../mock/feature/profile/domain/use_case/mock_refresh_profile_use_case.dart';
import '../../../../../mock/feature/project/domain/use_case/mock_refresh_projects_use_case.dart';
import '../../../../../mock/feature/service/domain/use_case/mock_refresh_services_use_case.dart';
import '../../../../../mock/feature/testimonial/domain/use_case/mock_refresh_testimonials_use_case.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  final earlier = DateTime.utc(2026, 10, 20);
  final later = DateTime.utc(2026, 10, 24);

  group('UpdatePortfolioUseCase', () {
    late MockPortfolioUpdateRepository repository;
    late MockRefreshProfileUseCase refreshProfileUseCase;
    late MockRefreshExperiencesUseCase refreshExperiencesUseCase;
    late MockRefreshAllExpertiseUseCase refreshAllExpertiseUseCase;
    late MockRefreshProjectsUseCase refreshProjectsUseCase;
    late MockRefreshServicesUseCase refreshServicesUseCase;
    late MockRefreshTestimonialsUseCase refreshTestimonialsUseCase;
    late UpdatePortfolioUseCase useCase;

    setUpAll(() {
      registerFallbackValue(PortfolioSection.profile);
      registerFallbackValue(DateTime(2026));
      registerFallbackValue(<PortfolioSection>{});
    });

    setUp(() {
      repository = MockPortfolioUpdateRepository()
        ..stubGetAppliedChangeTimes({})
        ..stubSetAppliedChangeTime()
        ..stubReportRefreshedSections();
      refreshProfileUseCase = MockRefreshProfileUseCase()
        ..stubCall(const Right(null));
      refreshExperiencesUseCase = MockRefreshExperiencesUseCase()
        ..stubCall(const Right(null));
      refreshAllExpertiseUseCase = MockRefreshAllExpertiseUseCase()
        ..stubCall(const Right(null));
      refreshProjectsUseCase = MockRefreshProjectsUseCase()
        ..stubCall(const Right(null));
      refreshServicesUseCase = MockRefreshServicesUseCase()
        ..stubCall(const Right(null));
      refreshTestimonialsUseCase = MockRefreshTestimonialsUseCase()
        ..stubCall(const Right(null));
      useCase = UpdatePortfolioUseCase(
        repository,
        refreshProfileUseCase,
        refreshExperiencesUseCase,
        refreshAllExpertiseUseCase,
        refreshProjectsUseCase,
        refreshServicesUseCase,
        refreshTestimonialsUseCase,
        MockLogReporter(),
      );
    });

    test('should refresh every section that changed after its last refresh '
        'when synced', () async {
      repository
        ..stubGetChangeTimes({
          PortfolioSection.profile: later,
          PortfolioSection.projects: later,
          PortfolioSection.services: earlier,
        })
        ..stubGetAppliedChangeTimes({
          PortfolioSection.profile: earlier,
          PortfolioSection.services: earlier,
        });

      final result = await useCase();

      expect(result.right, {
        PortfolioSection.profile,
        PortfolioSection.projects,
      });
      verify(() => refreshProfileUseCase()).called(1);
      verify(() => refreshProjectsUseCase()).called(1);
      verifyNever(() => refreshServicesUseCase());
      verify(
        () => repository.setAppliedChangeTime(PortfolioSection.profile, later),
      ).called(1);
      verify(
        () => repository.setAppliedChangeTime(PortfolioSection.projects, later),
      ).called(1);
      verify(
        () => repository.reportRefreshedSections({
          PortfolioSection.profile,
          PortfolioSection.projects,
        }),
      ).called(1);
    });

    test('should refresh each section with its own use case when all '
        'changed', () async {
      repository.stubGetChangeTimes({
        for (final section in PortfolioSection.values) section: later,
      });

      final result = await useCase();

      expect(result.right, PortfolioSection.values.toSet());
      verify(() => refreshProfileUseCase()).called(1);
      verify(() => refreshExperiencesUseCase()).called(1);
      verify(() => refreshAllExpertiseUseCase()).called(1);
      verify(() => refreshProjectsUseCase()).called(1);
      verify(() => refreshServicesUseCase()).called(1);
      verify(() => refreshTestimonialsUseCase()).called(1);
    });

    test('should keep a section outdated when its refresh fails', () async {
      repository.stubGetChangeTimes({
        PortfolioSection.profile: later,
        PortfolioSection.testimonials: later,
      });
      refreshTestimonialsUseCase.stubCall(
        const Left(RefreshTestimonialsNetworkFailure()),
      );

      final result = await useCase();

      expect(result.right, {PortfolioSection.profile});
      verifyNever(
        () => repository.setAppliedChangeTime(
          PortfolioSection.testimonials,
          any(),
        ),
      );
    });

    test('should report nothing when no section changed', () async {
      repository
        ..stubGetChangeTimes({PortfolioSection.profile: earlier})
        ..stubGetAppliedChangeTimes({PortfolioSection.profile: earlier});

      final result = await useCase();

      expect(result.right, isEmpty);
      verifyNever(() => repository.reportRefreshedSections(any()));
    });

    test('should run a second update after the first when called twice at '
        'once', () async {
      repository.stubGetChangeTimes({PortfolioSection.profile: later});
      var appliedChangeTimes = <PortfolioSection, DateTime>{};
      when(
        repository.getAppliedChangeTimes,
      ).thenAnswer((_) async => appliedChangeTimes);
      when(() => repository.setAppliedChangeTime(any(), any())).thenAnswer((
        invocation,
      ) async {
        appliedChangeTimes = {
          invocation.positionalArguments[0] as PortfolioSection:
              invocation.positionalArguments[1] as DateTime,
        };
      });

      final results = await Future.wait([
        Future.value(useCase()),
        Future.value(useCase()),
      ]);

      expect(results.first.right, {PortfolioSection.profile});
      expect(results.last.right, isEmpty);
      verify(() => refreshProfileUseCase()).called(1);
    });

    final failures = <(Object, Type)>[
      (const PortfolioNetworkException(), UpdatePortfolioNetworkFailure),
      (const PortfolioUnauthorizedException(), UpdatePortfolioNetworkFailure),
      (const PortfolioParsingException(), UpdatePortfolioDataFailure),
      (const PortfolioCacheException(), UpdatePortfolioDataFailure),
      (Exception('unexpected'), UpdatePortfolioUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when reading the change times throws $error',
        () async {
          repository.stubGetChangeTimesThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          verifyNever(() => refreshProfileUseCase());
        },
      );
    }
  });
}
