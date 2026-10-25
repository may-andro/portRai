import 'dart:async';

import 'package:log_reporter/log_reporter.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/domain/entity/_entity.dart';
import 'package:portrai/src/feature/portfolio/domain/exception/_exception.dart';
import 'package:portrai/src/feature/portfolio/domain/repository/_repository.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';
import 'package:use_case/use_case.dart';

sealed class UpdatePortfolioFailure extends BasicFailure {
  const UpdatePortfolioFailure({super.cause});
}

class UpdatePortfolioNetworkFailure extends UpdatePortfolioFailure {
  const UpdatePortfolioNetworkFailure({super.cause});
}

class UpdatePortfolioDataFailure extends UpdatePortfolioFailure {
  const UpdatePortfolioDataFailure({super.cause});
}

class UpdatePortfolioUnknownFailure extends UpdatePortfolioFailure {
  const UpdatePortfolioUnknownFailure({super.cause});
}

/// Refreshes the cached sections of the current locale that changed since
/// they were last refreshed, and returns them. A section that fails to
/// refresh keeps its cache and is tried again on the next update.
///
/// Registered once, so updates run one after another and never refresh the
/// same section twice at once.
@registerSingleton
class UpdatePortfolioUseCase
    extends BaseNoParamUseCase<Set<PortfolioSection>, UpdatePortfolioFailure> {
  UpdatePortfolioUseCase(
    this._portfolioUpdateRepository,
    this._refreshProfileUseCase,
    this._refreshExperiencesUseCase,
    this._refreshAllExpertiseUseCase,
    this._refreshProjectsUseCase,
    this._refreshServicesUseCase,
    this._refreshTestimonialsUseCase,
    this._logReporter,
  );

  static const _tag = 'UpdatePortfolioUseCase';

  final PortfolioUpdateRepository _portfolioUpdateRepository;
  final RefreshProfileUseCase _refreshProfileUseCase;
  final RefreshExperiencesUseCase _refreshExperiencesUseCase;
  final RefreshAllExpertiseUseCase _refreshAllExpertiseUseCase;
  final RefreshProjectsUseCase _refreshProjectsUseCase;
  final RefreshServicesUseCase _refreshServicesUseCase;
  final RefreshTestimonialsUseCase _refreshTestimonialsUseCase;
  final LogReporter _logReporter;

  Future<void> _pendingUpdate = Future.value();

  @protected
  @override
  Future<Either<UpdatePortfolioFailure, Set<PortfolioSection>>> execute() {
    final update = _pendingUpdate.then((_) => _update());
    _pendingUpdate = update.then((_) {}, onError: (_) {});
    return update;
  }

  Future<Either<UpdatePortfolioFailure, Set<PortfolioSection>>>
  _update() async {
    final changeTimes = await _portfolioUpdateRepository.getChangeTimes();
    final appliedChangeTimes = await _portfolioUpdateRepository
        .getAppliedChangeTimes();

    final refreshedSections = <PortfolioSection>{};
    for (final MapEntry(key: section, value: changedAt)
        in changeTimes.entries) {
      final appliedChangedAt = appliedChangeTimes[section];
      if (appliedChangedAt != null && !changedAt.isAfter(appliedChangedAt)) {
        continue;
      }
      final refreshEither = await _refresh(section);
      if (refreshEither.isLeft) {
        _logReporter.debug(
          'Failed to refresh ${section.name}, keeping the cached data',
          error: refreshEither.left,
          tag: _tag,
        );
        continue;
      }
      await _portfolioUpdateRepository.setAppliedChangeTime(section, changedAt);
      refreshedSections.add(section);
    }

    if (refreshedSections.isNotEmpty) {
      _portfolioUpdateRepository.reportRefreshedSections(refreshedSections);
    }
    return Right(refreshedSections);
  }

  Future<Either<Failure, void>> _refresh(PortfolioSection section) async {
    return switch (section) {
      PortfolioSection.profile => await _refreshProfileUseCase(),
      PortfolioSection.experiences => await _refreshExperiencesUseCase(),
      PortfolioSection.expertise => await _refreshAllExpertiseUseCase(),
      PortfolioSection.projects => await _refreshProjectsUseCase(),
      PortfolioSection.services => await _refreshServicesUseCase(),
      PortfolioSection.testimonials => await _refreshTestimonialsUseCase(),
    };
  }

  @protected
  @override
  UpdatePortfolioFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      PortfolioNetworkException() || PortfolioUnauthorizedException() =>
        UpdatePortfolioNetworkFailure(cause: e),
      PortfolioNotFoundException() ||
      PortfolioParsingException() ||
      PortfolioCacheException() => UpdatePortfolioDataFailure(cause: e),
      _ => UpdatePortfolioUnknownFailure(cause: e),
    };
  }
}
