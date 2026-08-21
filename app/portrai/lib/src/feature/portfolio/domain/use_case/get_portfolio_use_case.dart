import 'dart:async';

import 'package:log_reporter/log_reporter.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/domain/entity/_entity.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

sealed class GetPortfolioFailure extends BasicFailure {
  const GetPortfolioFailure({super.cause});
}

@Localizable('errorPortfolioNotFound')
class GetPortfolioNotFoundFailure extends GetPortfolioFailure {
  const GetPortfolioNotFoundFailure({super.cause});
}

@Localizable('errorPortfolioUnknown')
class GetPortfolioUnknownFailure extends GetPortfolioFailure {
  const GetPortfolioUnknownFailure({super.cause});
}

@register
class GetPortfolioUseCase
    extends BaseNoParamUseCase<PortfolioEntity, GetPortfolioFailure> {
  GetPortfolioUseCase(
    this._getProfileUseCase,
    this._allExpertiseUseCase,
    this._getProjectsUseCase,
    this._getServicesUseCase,
    this._getExperiencesUseCase,
    this._getTestimonialsUseCase,
    this._logReporter,
  );

  final GetProfileUseCase _getProfileUseCase;
  final GetAllExpertiseUseCase _allExpertiseUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final GetServicesUseCase _getServicesUseCase;
  final GetExperiencesUseCase _getExperiencesUseCase;
  final GetTestimonialsUseCase _getTestimonialsUseCase;
  final LogReporter _logReporter;

  @protected
  @override
  FutureOr<Either<GetPortfolioFailure, PortfolioEntity>> execute() async {
    // Fetch profile data - this is critical, fail if it fails
    final profileResult = await _getProfileUseCase();

    // If profile fetch fails, return the failure immediately
    final ProfileEntity profile;
    if (profileResult.isLeft) {
      return Left(GetPortfolioNotFoundFailure(cause: profileResult.left));
    } else {
      profile = profileResult.right;
    }

    // Fetch all expertise - optional, use empty list on failure
    final expertiseResult = await _allExpertiseUseCase();
    final expertises = expertiseResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch expertise for portfolio, using empty list',
        error: failure,
      );
      return <ExpertiseEntity>[];
    }, (expertises) => expertises);

    // Fetch all projects - optional, use empty list on failure
    final projectsResult = await _getProjectsUseCase();
    final projects = projectsResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch projects for portfolio, using empty list',
        error: failure,
      );
      return <ProjectEntity>[];
    }, (projects) => projects);

    // Fetch all services - optional, use empty list on failure
    final servicesResult = await _getServicesUseCase();
    final services = servicesResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch services for portfolio, using empty list',
        error: failure,
      );
      return <ServiceEntity>[];
    }, (services) => services);

    // Fetch all experiences - optional, use empty list on failure
    final experiencesResult = await _getExperiencesUseCase();
    final experiences = experiencesResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch experiences for portfolio, using empty list',
        error: failure,
      );
      return <ExperienceEntity>[];
    }, (experiences) => experiences);

    // Fetch all testimonials - optional, use empty list on failure
    final testimonialsResult = await _getTestimonialsUseCase();
    final testimonials = testimonialsResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch testimonials for portfolio, using empty list',
        error: failure,
      );
      return <TestimonialEntity>[];
    }, (testimonials) => testimonials);

    // Create and return portfolio entity
    final portfolio = PortfolioEntity(
      profile: profile,
      expertises: expertises,
      projects: projects,
      services: services,
      experiences: experiences,
      testimonials: testimonials,
    );

    return Right(portfolio);
  }

  @protected
  @override
  GetPortfolioFailure mapErrorToFailure(Object e, StackTrace st) {
    return GetPortfolioUnknownFailure(cause: e);
  }
}
