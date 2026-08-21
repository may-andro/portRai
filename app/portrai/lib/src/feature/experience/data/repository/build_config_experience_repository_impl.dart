import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/repository/asset_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/data/repository/remote_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

@Register(as: ExperienceRepository)
class BuildConfigExperienceRepositoryImpl implements ExperienceRepository {
  BuildConfigExperienceRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteExperienceRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetExperienceRepositoryImpl) this._demoDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final ExperienceRepository _remoteDelegateRepository;
  final ExperienceRepository _demoDelegateRepository;

  @override
  Future<void> cacheExperience(ExperienceEntity experience) {
    return _delegateRepository.cacheExperience(experience);
  }

  @override
  Future<ExperienceEntity> getExperience(String id) {
    return _delegateRepository.getExperience(id);
  }

  @override
  Future<List<ExperienceEntity>> getExperiences() {
    return _delegateRepository.getExperiences();
  }

  ExperienceRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _demoDelegateRepository;
    }
  }
}
