import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/data/cache/_cache.dart';
import 'package:portrai/src/feature/project/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

@register
class CacheProjectRepositoryImpl implements ProjectRepository {
  CacheProjectRepositoryImpl(this._projectCache, this._mapper, this._appLocale);

  final ProjectCache _projectCache;
  final ProjectMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheProject(ProjectEntity project) async {
    try {
      return await _projectCache.put(_mapper.from(project));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ProjectCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ProjectCacheException(
        cause: 'Unexpected error while caching project: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ProjectEntity>> getProjects() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final projectList = await _projectCache.query(
        conditions: {'locale': currentLocale},
      );

      if (projectList.isEmpty) {
        throw const ProjectNotFoundException(
          cause: 'No projects found in cache for current locale',
        );
      }

      return projectList.map(_mapper.to).toList();
    } on ProjectNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ProjectCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ProjectNotFoundException(
        cause: 'Unexpected error while retrieving projects: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProjectEntity> getProject(String id) async {
    try {
      final currentLocale = _appLocale.languageCode;

      final project = await _projectCache.get(
        conditions: {'id': id, 'locale': currentLocale},
      );

      if (project == null) {
        throw ProjectNotFoundException(
          cause: 'Project with id $id not found in cache for current locale',
        );
      }

      return _mapper.to(project);
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ProjectCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } on ProjectNotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      throw ProjectNotFoundException(
        cause: 'Unexpected error while retrieving project: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
