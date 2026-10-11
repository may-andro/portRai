import 'package:feature_flag/feature_flag.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/data/mapper/app_feature_flag_mapper.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';
import 'package:portrai/src/feature/feature_flag/domain/registry/_registry.dart';
import 'package:portrai/src/feature/feature_flag/domain/repository/_repository.dart';

@Register(as: AppFeatureFlagRepository)
class AppFeatureFlagRepositoryImpl implements AppFeatureFlagRepository {
  AppFeatureFlagRepositoryImpl(
    this._controller,
    this._mapper, {
    @Inject(AppFeatureFlagChanges) this._changes,
  });

  final FeatureFlagController _controller;
  final AppFeatureFlagMapper _mapper;
  final AppFeatureFlagChanges? _changes;

  @override
  bool isFeatureEnabled(AppFeatureFlagDefinition definition) {
    return _controller.isFeatureEnabled(definition.key);
  }

  @override
  Future<void> updateFeatureFlag(AppFeatureFlagEntity flag) async {
    final layerFlag = _mapper.from(flag);
    final pending = _controller.updateFeatureFlag(layerFlag);
    // The controller updates memory before awaiting persistence.
    _changes?.notify(flag.flag.key);
    await pending;
  }

  @override
  Future<void> reset() async {
    try {
      final pending = _controller.reset();
      _changes?.notify();
      await pending;
    } finally {
      _changes?.notify();
    }
  }

  @override
  AppFeatureFlagEntity getFeatureFlag(AppFeatureFlagDefinition definition) {
    try {
      final flags = _controller.getAllFeatureFlags();
      final layerFlag = flags.firstWhere((f) => f.key == definition.key);
      return _mapper.to(layerFlag, definition);
    } catch (e) {
      return AppFeatureFlagEntity(
        flag: definition,
        isEnabled: definition.defaultValue,
        isOverridden: false,
      );
    }
  }
}
