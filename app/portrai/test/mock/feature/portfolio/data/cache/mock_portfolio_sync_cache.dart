import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/data/cache/portfolio_sync_cache.dart';

class MockPortfolioSyncCache extends Mock implements PortfolioSyncCache {}

extension MockPortfolioSyncCacheStub on MockPortfolioSyncCache {
  void stubGet(Map<String, int>? syncedTimes) {
    when(get).thenAnswer((_) async => syncedTimes);
  }

  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }
}
