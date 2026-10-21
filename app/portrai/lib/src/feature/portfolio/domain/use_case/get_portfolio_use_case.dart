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

  static const _tag = 'GetPortfolioUseCase';

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
    // The sections are independent, so they are fetched concurrently.
    final (
      profileResult,
      expertiseResult,
      projectsResult,
      servicesResult,
      experiencesResult,
      testimonialsResult,
    ) = await (
      Future.value(_getProfileUseCase()),
      Future.value(_allExpertiseUseCase()),
      Future.value(_getProjectsUseCase()),
      Future.value(_getServicesUseCase()),
      Future.value(_getExperiencesUseCase()),
      Future.value(_getTestimonialsUseCase()),
    ).wait;

    // Profile data is critical, fail if it fails
    final ProfileEntity profile;
    if (profileResult.isLeft) {
      return Left(GetPortfolioNotFoundFailure(cause: profileResult.left));
    } else {
      profile = profileResult.right;
    }

    // Expertise is optional, use empty list on failure
    final expertises = expertiseResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch expertise for portfolio, using empty list',
        error: failure,
        tag: _tag,
      );
      return <ExpertiseEntity>[];
    }, (expertises) => expertises);

    // Projects are optional, use empty list on failure
    final projects = projectsResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch projects for portfolio, using empty list',
        error: failure,
        tag: _tag,
      );
      return <ProjectEntity>[];
    }, (projects) => projects);

    // Services are optional, use empty list on failure
    final services = servicesResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch services for portfolio, using empty list',
        error: failure,
        tag: _tag,
      );
      return <ServiceEntity>[];
    }, (services) => services);

    // Experiences are optional, use empty list on failure
    final experiences = experiencesResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch experiences for portfolio, using empty list',
        error: failure,
        tag: _tag,
      );
      return <ExperienceEntity>[];
    }, (experiences) => experiences);

    // Testimonials are optional, use empty list on failure
    final testimonials = testimonialsResult.fold((failure) {
      _logReporter.debug(
        'Failed to fetch testimonials for portfolio, using empty list',
        error: failure,
        tag: _tag,
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
