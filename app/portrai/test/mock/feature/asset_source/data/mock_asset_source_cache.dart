import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/data/cache/_cache.dart';
import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';

class MockAssetSourceCache extends Mock implements AssetSourceCache {}

extension MockAssetSourceCacheStub on MockAssetSourceCache {
  void stubGet(AssetSource? source) {
    when(get).thenAnswer((_) async => source);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }
}
