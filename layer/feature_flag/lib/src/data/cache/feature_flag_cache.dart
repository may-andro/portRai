import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:feature_flag/src/feature_flag.dart';

class FeatureFlagCache extends DBCache<FeatureFlag> {
  FeatureFlagCache({super.adapter});

  @override
  String get dbName => 'feature_flag_db';

  @override
  String get tableName => 'feature_table';

  @override
  int get tableVersion => 1;

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
          name: 'remote_value',
          type: DbColumnType.integer,
        ),
        const DbColumnDefinition(
          name: 'updated_at',
          type: DbColumnType.integer,
        ),
      ];

  @override
  List<String> get primaryKeyColumns => ['name'];

  @override
  FeatureFlag deserialize(Map<String, dynamic> map) {
    final data = Map<String, dynamic>.from(map);
    data['key'] = data['name'];
    data['is_enabled'] = (data['is_enabled'] as int) == 1;
    data['is_overridden'] = (data['is_overridden'] as int?) == 1;
    
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
    data['remote_value'] = model.remoteValue != null ? (model.remoteValue! ? 1 : 0) : null;
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
      remoteValue: flag.remoteValue,
    );
    await put(overriddenFlag);
  }

  Future<void> resetOverride(String key) async {
    final flag = await get(conditions: {'name': key});
    if (flag == null || !flag.isOverridden) return;
    
    if (flag.remoteValue != null) {
      final restoredFlag = FeatureFlag(
        key: flag.key,
        isEnabled: flag.remoteValue!,
        isOverridden: false,
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
