import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/data/repository/asset_project_repository_impl.dart';
import 'package:portrai/src/feature/project/data/repository/remote_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

@Register(as: ProjectRepository)
class BuildConfigProjectRepositoryImpl implements ProjectRepository {
  BuildConfigProjectRepositoryImpl(
    this._buildConfig,
    @Inject(RemoteProjectRepositoryImpl) this._remoteDelegateRepository,
    @Inject(AssetProjectRepositoryImpl) this._demoDelegateRepository,
  );

  final BuildConfig _buildConfig;
  final ProjectRepository _remoteDelegateRepository;
  final ProjectRepository _demoDelegateRepository;

  @override
  Future<void> cacheProjects(List<ProjectEntity> projects) {
    return _delegateRepository.cacheProjects(projects);
  }

  @override
  Future<List<ProjectEntity>> getProjects() {
    return _delegateRepository.getProjects();
  }

  @override
  Future<ProjectEntity> getProject(String id) {
    return _delegateRepository.getProject(id);
  }

  @override
  Future<void> refreshProjects() {
    return _delegateRepository.refreshProjects();
  }

  ProjectRepository get _delegateRepository {
    switch (_buildConfig.buildEnvironment) {
      case BuildEnvironment.prod:
        return _remoteDelegateRepository;
      case BuildEnvironment.staging:
        return _demoDelegateRepository;
    }
  }
}
