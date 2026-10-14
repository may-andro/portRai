import 'package:design_system/design_system.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/data/cache/_cache.dart';
import 'package:portrai/src/feature/design_system/domain/_domain.dart';

@Register(as: DesignSystemRepository)
class DesignSystemRepositoryImpl implements DesignSystemRepository {
  DesignSystemRepositoryImpl(this._cache);

  final DesignSystemCache _cache;

  @override
  Future<DesignSystem?> getDesignSystem() async {
    try {
      return await _cache.get();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setDesignSystem(DesignSystem designSystem) async {
    await _cache.put(designSystem);
  }

  @override
  Future<void> clearDesignSystem() async {
    await _cache.delete();
  }
}
