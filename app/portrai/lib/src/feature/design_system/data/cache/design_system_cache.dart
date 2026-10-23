import 'package:cache/cache.dart';
import 'package:design_system/design_system.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';

@registerSingleton
class DesignSystemCache extends KeyValueCache<DesignSystem> {
  DesignSystemCache() : super('design_system_cache');

  /// A chosen design system lasts until the end of the month it was chosen
  /// in, so the next month starts with its own design system again. A month
  /// has no fixed length, so the time to live is worked out from when the
  /// design system was cached.
  @override
  Duration get timeToLive =>
      timeLeftInMonth(DateTime.fromMillisecondsSinceEpoch(lastCachedTimestamp));

  /// The time from [cachedAt] to the start of the next month.
  @visibleForTesting
  static Duration timeLeftInMonth(DateTime cachedAt) =>
      DateTime(cachedAt.year, cachedAt.month + 1).difference(cachedAt);

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
