import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/portfolio/data/cache/_cache.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';

/// Reads the change times the portfolio functions write to
/// `portfolio_versions/{locale}`, one field per section.
@RegisterSingleton(as: PortfolioUpdateRepository)
class FirestorePortfolioUpdateRepository implements PortfolioUpdateRepository {
  FirestorePortfolioUpdateRepository(
    this._firestoreController,
    this._portfolioUpdateCache,
    this._appLocale,
    this._buildConfig,
  );

  static const _collection = 'portfolio_versions';

  final FbFirestoreController _firestoreController;
  final PortfolioUpdateCache _portfolioUpdateCache;
  final AppLocale _appLocale;
  final BuildConfig _buildConfig;

  final _refreshedSectionsController =
      StreamController<Set<PortfolioSection>>.broadcast();

  @override
  Future<Map<PortfolioSection, DateTime>> getChangeTimes() async {
    // Staging builds show the bundled portfolio, which never changes.
    if (_buildConfig.buildEnvironment == BuildEnvironment.staging) {
      return const {};
    }
    final Map<String, dynamic>? document;
    try {
      document = await _firestoreController.getDocumentFromCollection(
        _collection,
        _appLocale.languageCode,
      );
    } on FirestoreDocumentNotFoundException {
      return const {};
    } on FirestorePermissionDeniedException catch (e, st) {
      throw PortfolioUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw PortfolioParsingException(cause: e, stackTrace: st);
    } on FirestoreException catch (e, st) {
      throw PortfolioNetworkException(cause: e, stackTrace: st);
    }
    if (document == null) return const {};
    return {
      for (final section in PortfolioSection.values)
        if (document[section.name] case final Timestamp changedAt)
          section: changedAt.toDate(),
    };
  }

  @override
  Future<Map<PortfolioSection, DateTime>> getAppliedChangeTimes() async {
    final appliedTimes = await _readAppliedTimes();
    return {
      for (final section in PortfolioSection.values)
        if (appliedTimes[_key(section)] case final int milliseconds)
          section: DateTime.fromMillisecondsSinceEpoch(milliseconds),
    };
  }

  @override
  Future<void> setAppliedChangeTime(
    PortfolioSection section,
    DateTime changedAt,
  ) async {
    final appliedTimes = await _readAppliedTimes();
    try {
      await _portfolioUpdateCache.put({
        ...appliedTimes,
        _key(section): changedAt.millisecondsSinceEpoch,
      });
    } catch (e, st) {
      throw PortfolioCacheException(cause: e, stackTrace: st);
    }
  }

  @override
  Stream<Set<PortfolioSection>> get refreshedSections =>
      _refreshedSectionsController.stream;

  @override
  void reportRefreshedSections(Set<PortfolioSection> sections) {
    _refreshedSectionsController.add(sections);
  }

  Future<Map<String, int>> _readAppliedTimes() async {
    try {
      return await _portfolioUpdateCache.get() ?? const {};
    } catch (e, st) {
      throw PortfolioCacheException(cause: e, stackTrace: st);
    }
  }

  String _key(PortfolioSection section) =>
      '${_appLocale.languageCode}/${section.name}';
}
