import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:feature_flag/src/feature_flag.dart';

/// Caches [FeatureFlag]s, including developer overrides, for a single host
/// app.
///
/// [appId] namespaces the underlying database so that multiple apps
/// embedding this package on the same device (e.g. `portrai`, `storybook`)
/// never share, or collide on, cached flag values - even if they happen to
/// use the same flag key.
class FeatureFlagCache extends DBCache<FeatureFlag> {
  FeatureFlagCache({required this.appId, super.adapter});

  final String appId;

  @override
  String get dbName => '${appId}_feature_flag_db';

  @override
  String get tableName => 'feature_table';

  @override
  int get tableVersion => 2;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'name', nullable: false),
    const DbColumnDefinition(
      name: 'is_enabled',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(
      name: 'is_overridden',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(
      name: 'has_remote_source',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(name: 'remote_value', type: DbColumnType.integer),
    const DbColumnDefinition(name: 'updated_at', type: DbColumnType.integer),
  ];

  @override
  List<String> get primaryKeyColumns => ['name'];

  @override
  FeatureFlag deserialize(Map<String, dynamic> map) {
    final data = Map<String, dynamic>.from(map);
    data['key'] = data['name'];
    data['is_enabled'] = (data['is_enabled'] as int) == 1;
    data['is_overridden'] = (data['is_overridden'] as int?) == 1;
    data['has_remote_source'] = (data['has_remote_source'] as int?) == 1;

    if (data['remote_value'] != null) {
      data['remote_value'] = (data['remote_value'] as int) == 1;
    }

    return FeatureFlag.fromJson(data);
  }

  @override
  Map<String, dynamic> serialize(FeatureFlag model) {
    final data = model.toJson();

    data['name'] = model.key;
    data['is_enabled'] = model.isEnabled ? 1 : 0;
    data['is_overridden'] = model.isOverridden ? 1 : 0;
    data['has_remote_source'] = model.hasRemoteSource ? 1 : 0;
    data['remote_value'] = model.remoteValue != null
        ? (model.remoteValue! ? 1 : 0)
        : null;
    data['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    data.remove('key');

    return data;
  }

  @override
  Duration get timeToLive => 2.days;

  Future<void> putOverride(FeatureFlag flag) async {
    final overriddenFlag = FeatureFlag(
      key: flag.key,
      isEnabled: flag.isEnabled,
      isOverridden: true,
      hasRemoteSource: flag.hasRemoteSource,
      remoteValue: flag.remoteValue,
    );
    await put(overriddenFlag);
  }

  Future<void> resetOverride(String key) async {
    final flag = await get(conditions: {'name': key});
    if (flag == null || !flag.isOverridden) return;

    if (flag.hasRemoteSource && flag.remoteValue != null) {
      final restoredFlag = FeatureFlag(
        key: flag.key,
        isEnabled: flag.remoteValue!,
        hasRemoteSource: true,
        remoteValue: flag.remoteValue,
      );
      await put(restoredFlag);
    } else {
      await delete({'name': key});
    }
  }

  Future<void> clearAllOverrides() async {
    final allFlags = await getAll();
    final overriddenFlags = allFlags.where((f) => f.isOverridden).toList();

    for (final flag in overriddenFlags) {
      await resetOverride(flag.key);
    }
  }

  Future<List<FeatureFlag>> getOverriddenFlags() async {
    final allFlags = await getAll();
    return allFlags.where((f) => f.isOverridden).toList();
  }
}
