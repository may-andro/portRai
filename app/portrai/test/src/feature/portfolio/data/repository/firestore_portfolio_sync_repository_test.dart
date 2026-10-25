import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/data/repository/firestore_portfolio_sync_repository.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';

import '../../../../../mock/feature/portfolio/data/cache/mock_portfolio_sync_cache.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';

void main() {
  final changedAt = DateTime.utc(2026, 10, 24, 10);

  group('FirestorePortfolioSyncRepository', () {
    late MockFbFirestoreController firestoreController;
    late MockPortfolioSyncCache portfolioSyncCache;

    setUpAll(() {
      registerFallbackValue(<String, int>{});
    });

    setUp(() {
      firestoreController = MockFbFirestoreController();
      portfolioSyncCache = MockPortfolioSyncCache();
    });

    FirestorePortfolioSyncRepository buildRepository({
      BuildEnvironment buildEnvironment = BuildEnvironment.prod,
    }) {
      return FirestorePortfolioSyncRepository(
        firestoreController,
        portfolioSyncCache,
        AppLocale('es'),
        BuildConfig(buildEnvironment: buildEnvironment),
      );
    }

    test('should read the change time of each section when the document '
        'has them', () async {
      firestoreController.stubGetDocumentFromCollection({
        'profile': Timestamp.fromDate(changedAt),
        'projects': Timestamp.fromDate(changedAt),
        'unknown': Timestamp.fromDate(changedAt),
        'services': 'not a timestamp',
      });

      final changeTimes = await buildRepository().getChangeTimes();

      expect(changeTimes, {
        PortfolioSection.profile: changedAt.toLocal(),
        PortfolioSection.projects: changedAt.toLocal(),
      });
      verify(
        () => firestoreController.getDocumentFromCollection(
          'portfolio_versions',
          'es',
        ),
      ).called(1);
    });

    test(
      'should return no change times when the document is missing',
      () async {
        firestoreController.stubGetDocumentFromCollection(null);

        expect(await buildRepository().getChangeTimes(), isEmpty);
      },
    );

    test('should not read Firestore when the build shows the bundled '
        'portfolio', () async {
      final changeTimes = await buildRepository(
        buildEnvironment: BuildEnvironment.staging,
      ).getChangeTimes();

      expect(changeTimes, isEmpty);
      verifyZeroInteractions(firestoreController);
    });

    final failures = <(Object, Matcher)>[
      (
        const FirestorePermissionDeniedException(
          'get',
          'denied',
          StackTrace.empty,
        ),
        isA<PortfolioUnauthorizedException>(),
      ),
      (
        const FirestoreInvalidDataException('profile', 'bad', StackTrace.empty),
        isA<PortfolioParsingException>(),
      ),
      (
        const FirestoreNetworkException('offline', StackTrace.empty),
        isA<PortfolioNetworkException>(),
      ),
    ];

    for (final (error, matchesException) in failures) {
      test('should map the Firestore error when it throws $error', () async {
        firestoreController.stubGetDocumentFromCollectionThrows(error);

        await expectLater(
          buildRepository().getChangeTimes,
          throwsA(matchesException),
        );
      });
    }

    test('should read the synced change times of the current locale only '
        'when asked', () async {
      portfolioSyncCache.stubGet({
        'es/profile': changedAt.millisecondsSinceEpoch,
        'en/projects': changedAt.millisecondsSinceEpoch,
      });

      final syncedChangeTimes = await buildRepository().getSyncedChangeTimes();

      expect(syncedChangeTimes, {
        PortfolioSection.profile: DateTime.fromMillisecondsSinceEpoch(
          changedAt.millisecondsSinceEpoch,
        ),
      });
    });

    test('should keep the other synced times when one is set', () async {
      portfolioSyncCache
        ..stubGet({'en/projects': 1})
        ..stubPut();

      await buildRepository().setSyncedChangeTime(
        PortfolioSection.profile,
        changedAt,
      );

      verify(
        () => portfolioSyncCache.put({
          'en/projects': 1,
          'es/profile': changedAt.millisecondsSinceEpoch,
        }),
      ).called(1);
    });

    test('should throw PortfolioCacheException when the synced times cannot '
        'be read', () async {
      portfolioSyncCache.stubGetThrows(Exception('storage failed'));

      await expectLater(
        buildRepository().getSyncedChangeTimes,
        throwsA(isA<PortfolioCacheException>()),
      );
    });

    test('should emit the reported sections to listeners', () async {
      final repository = buildRepository();
      final sections = expectLater(
        repository.refreshedSections,
        emits({PortfolioSection.services}),
      );

      repository.reportRefreshedSections({PortfolioSection.services});

      await sections;
    });
  });
}
