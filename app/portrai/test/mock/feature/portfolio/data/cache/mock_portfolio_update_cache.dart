import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/data/cache/portfolio_update_cache.dart';

class MockPortfolioUpdateCache extends Mock implements PortfolioUpdateCache {}

extension MockPortfolioUpdateCacheStub on MockPortfolioUpdateCache {
  void stubGet(Map<String, int>? appliedTimes) {
    when(get).thenAnswer((_) async => appliedTimes);
  }

  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }
}
