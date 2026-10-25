import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';

import '../../../../../mock/feature/portfolio/domain/repository/mock_portfolio_sync_repository.dart';

void main() {
  group('WatchRefreshedPortfolioSectionsUseCase', () {
    test('should emit the refreshed sections when syncs refresh any', () async {
      final repository = MockPortfolioSyncRepository()
        ..stubRefreshedSections(
          Stream.value({PortfolioSection.profile, PortfolioSection.projects}),
        );

      final results = await WatchRefreshedPortfolioSectionsUseCase(
        repository,
      )().toList();

      expect(results.single.right, {
        PortfolioSection.profile,
        PortfolioSection.projects,
      });
    });

    test('should emit a failure when the stream errors', () async {
      final repository = MockPortfolioSyncRepository()
        ..stubRefreshedSections(Stream.error(Exception('boom')));

      final results = await WatchRefreshedPortfolioSectionsUseCase(
        repository,
      )().toList();

      expect(
        results.single.left,
        isA<WatchRefreshedPortfolioSectionsUnknownFailure>(),
      );
    });
  });
}
