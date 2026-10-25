import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';

/// The change time each section was last refreshed for, in milliseconds
/// since the epoch, keyed by `<locale>/<section>`.
@registerSingleton
class PortfolioUpdateCache extends KeyValueCache<Map<String, int>> {
  PortfolioUpdateCache() : super('portfolio_update_cache');

  @override
  Map<String, int> deserializeValue(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value as int));
  }

  @override
  Map<String, dynamic> serializeValue(Map<String, int> value) => value;
}
