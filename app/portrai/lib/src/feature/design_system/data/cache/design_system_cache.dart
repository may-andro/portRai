import 'package:cache/cache.dart';
import 'package:design_system/design_system.dart';
import 'package:module_injector/module_injector.dart';

@registerSingleton
class DesignSystemCache extends KeyValueCache<DesignSystem> {
  DesignSystemCache() : super('design_system_cache');

  @override
  DesignSystem deserializeValue(Map<String, dynamic> map) {
    return DesignSystem.values.asNameMap()[map['designSystem']] ??
        (throw const FormatException('Unknown design system'));
  }

  @override
  Map<String, dynamic> serializeValue(DesignSystem value) => {
    'designSystem': value.name,
  };
}
