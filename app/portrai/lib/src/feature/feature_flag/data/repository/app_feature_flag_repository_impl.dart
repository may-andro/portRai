import 'package:feature_flag/feature_flag.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/data/mapper/app_feature_flag_mapper.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/_entity.dart';
import 'package:portrai/src/feature/feature_flag/domain/repository/_repository.dart';

@Register(as: AppFeatureFlagRepository)
class AppFeatureFlagRepositoryImpl implements AppFeatureFlagRepository {
  AppFeatureFlagRepositoryImpl(this._controller, this._mapper);

  final FeatureFlagController _controller;
  final AppFeatureFlagMapper _mapper;

  @override
  bool isFeatureEnabled(AppFeatureFlagDefinition definition) {
    try {
      return _controller.isFeatureEnabled(definition.key);
    } catch (e) {
      return definition.defaultValue;
    }
  }

  @override
  Future<void> updateFeatureFlag(AppFeatureFlagEntity flag) async {
    final layerFlag = _mapper.from(flag);
    await _controller.updateFeatureFlag(layerFlag);
  }

  @override
  Future<void> reset() => _controller.reset();

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
