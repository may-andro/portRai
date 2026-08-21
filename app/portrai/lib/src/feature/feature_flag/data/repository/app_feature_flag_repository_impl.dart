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
  List<AppFeatureFlagEntity> getAllFeatureFlags() {
    return AppFeatureFlag.values.map(getFeatureFlag).toList();
  }

  @override
  bool isFeatureEnabled(AppFeatureFlag flag) {
    try {
      return _controller.isFeatureEnabled(flag.key);
    } catch (e) {
      return flag.defaultValue;
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
  AppFeatureFlagEntity getFeatureFlag(AppFeatureFlag flag) {
    try {
      final flags = _controller.getAllFeatureFlags();
      final layerFlag = flags.firstWhere((f) => f.key == flag.key);
      return _mapper.to(layerFlag);
    } catch (e) {
      return AppFeatureFlagEntity(
        flag: flag,
        isEnabled: flag.defaultValue,
        isOverridden: false,
      );
    }
  }
}
