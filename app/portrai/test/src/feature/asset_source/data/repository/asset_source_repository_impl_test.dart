import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/asset_source/data/repository/asset_source_repository_impl.dart';

import '../../../../../mock/feature/asset_source/data/mock_asset_source_cache.dart';

void main() {
  group('AssetSourceRepositoryImpl', () {
    late MockAssetSourceCache cache;
    late AssetSourceRepositoryImpl repository;

    setUpAll(() => registerFallbackValue(AssetSource.real));

    setUp(() {
      cache = MockAssetSourceCache();
      repository = AssetSourceRepositoryImpl(cache);
    });

    test('should return real when nothing is stored', () async {
      cache.stubGet(null);

      expect(await repository.getAssetSource(), AssetSource.real);
    });

    test('should return the stored source when one is stored', () async {
      cache.stubGet(AssetSource.template);

      expect(await repository.getAssetSource(), AssetSource.template);
    });

    test('should persist the source when setAssetSource is called', () async {
      cache.stubPut();

      await repository.setAssetSource(AssetSource.template);

      verify(() => cache.put(AssetSource.template)).called(1);
    });
  });
}
