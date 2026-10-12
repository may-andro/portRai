import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/data/cache/_cache.dart';
import 'package:portrai/src/feature/asset_source/domain/_domain.dart';

@Register(as: AssetSourceRepository)
class AssetSourceRepositoryImpl implements AssetSourceRepository {
  AssetSourceRepositoryImpl(this._cache);

  final AssetSourceCache _cache;

  @override
  Future<AssetSource> getAssetSource() async {
    return await _cache.get() ?? AssetSource.real;
  }

  @override
  Future<void> setAssetSource(AssetSource source) async {
    await _cache.put(source);
  }
}
