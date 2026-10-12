import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';

abstract class AssetSourceRepository {
  Future<AssetSource> getAssetSource();

  Future<void> setAssetSource(AssetSource source);
}
