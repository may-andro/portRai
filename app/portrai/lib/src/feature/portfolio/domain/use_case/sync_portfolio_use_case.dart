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

sealed class SyncPortfolioFailure extends BasicFailure {
  const SyncPortfolioFailure({super.cause});
}

class SyncPortfolioNetworkFailure extends SyncPortfolioFailure {
  const SyncPortfolioNetworkFailure({super.cause});
}

class SyncPortfolioDataFailure extends SyncPortfolioFailure {
  const SyncPortfolioDataFailure({super.cause});
}

class SyncPortfolioUnknownFailure extends SyncPortfolioFailure {
  const SyncPortfolioUnknownFailure({super.cause});
}

/// Refreshes the cached sections of the current locale that changed since
/// they were last refreshed, and returns them. A section that fails to
/// refresh keeps its cache and is tried again on the next sync.
///
/// Registered once, so syncs run one after another and never refresh the
/// same section twice at once.
@registerSingleton
class SyncPortfolioUseCase
    extends BaseNoParamUseCase<Set<PortfolioSection>, SyncPortfolioFailure> {
  SyncPortfolioUseCase(
    this._portfolioSyncRepository,
    this._refreshProfileUseCase,
    this._refreshExperiencesUseCase,
    this._refreshAllExpertiseUseCase,
    this._refreshProjectsUseCase,
    this._refreshServicesUseCase,
    this._refreshTestimonialsUseCase,
    this._logReporter,
  );

  static const _tag = 'SyncPortfolioUseCase';

  final PortfolioSyncRepository _portfolioSyncRepository;
  final RefreshProfileUseCase _refreshProfileUseCase;
  final RefreshExperiencesUseCase _refreshExperiencesUseCase;
  final RefreshAllExpertiseUseCase _refreshAllExpertiseUseCase;
  final RefreshProjectsUseCase _refreshProjectsUseCase;
  final RefreshServicesUseCase _refreshServicesUseCase;
  final RefreshTestimonialsUseCase _refreshTestimonialsUseCase;
  final LogReporter _logReporter;

  Future<void> _pendingSync = Future.value();

  @protected
  @override
  Future<Either<SyncPortfolioFailure, Set<PortfolioSection>>> execute() {
    final sync = _pendingSync.then((_) => _sync());
    _pendingSync = sync.then((_) {}, onError: (_) {});
    return sync;
  }

  Future<Either<SyncPortfolioFailure, Set<PortfolioSection>>> _sync() async {
    final changeTimes = await _portfolioSyncRepository.getChangeTimes();
    final syncedChangeTimes = await _portfolioSyncRepository
        .getSyncedChangeTimes();

    final refreshedSections = <PortfolioSection>{};
    for (final MapEntry(key: section, value: changedAt)
        in changeTimes.entries) {
      final syncedChangedAt = syncedChangeTimes[section];
      if (syncedChangedAt != null && !changedAt.isAfter(syncedChangedAt)) {
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
      await _portfolioSyncRepository.setSyncedChangeTime(section, changedAt);
      refreshedSections.add(section);
    }

    if (refreshedSections.isNotEmpty) {
      _portfolioSyncRepository.reportRefreshedSections(refreshedSections);
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
  SyncPortfolioFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      PortfolioNetworkException() ||
      PortfolioUnauthorizedException() => SyncPortfolioNetworkFailure(cause: e),
      PortfolioNotFoundException() ||
      PortfolioParsingException() ||
      PortfolioCacheException() => SyncPortfolioDataFailure(cause: e),
      _ => SyncPortfolioUnknownFailure(cause: e),
    };
  }
}
