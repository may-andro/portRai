import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/data/repository/asset_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/data/repository/remote_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

@Register(as: ExpertiseRepository)
class BuildConfigExpertiseRepositoryImpl implements ExpertiseRepository {
  BuildConfigExpertiseRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteExpertiseRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetExpertiseRepositoryImpl) this._assetDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final ExpertiseRepository _remoteDelegateRepository;
  final ExpertiseRepository _assetDelegateRepository;

  @override
  Future<void> cacheExpertise(ExpertiseEntity expert) {
    return _delegateRepository.cacheExpertise(expert);
  }

  @override
  Future<List<ExpertiseEntity>> getAllExpertise() {
    return _delegateRepository.getAllExpertise();
  }

  ExpertiseRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _assetDelegateRepository;
    }
  }
}
