import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';

@registerSingleton
class AssetSourceCache extends KeyValueCache<AssetSource> {
  AssetSourceCache() : super('asset_source_cache');

  @override
  AssetSource deserializeValue(Map<String, dynamic> map) {
    return AssetSource.values.asNameMap()[map['source']] ?? AssetSource.real;
  }

  @override
  Map<String, dynamic> serializeValue(AssetSource value) => {
    'source': value.name,
  };
}
