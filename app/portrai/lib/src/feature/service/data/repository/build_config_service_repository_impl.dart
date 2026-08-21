import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/data/repository/asset_service_repository_impl.dart';
import 'package:portrai/src/feature/service/data/repository/remote_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@Register(as: ServiceRepository)
class BuildConfigServiceRepositoryImpl implements ServiceRepository {
  BuildConfigServiceRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteServiceRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetServiceRepositoryImpl) this._demoDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final ServiceRepository _remoteDelegateRepository;
  final ServiceRepository _demoDelegateRepository;

  @override
  Future<void> cacheService(ServiceEntity expert) {
    return _delegateRepository.cacheService(expert);
  }

  @override
  Future<List<ServiceEntity>> getServices() {
    return _delegateRepository.getServices();
  }

  ServiceRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _demoDelegateRepository;
    }
  }
}
