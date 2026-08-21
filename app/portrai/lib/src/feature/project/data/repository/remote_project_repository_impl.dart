import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/project/data/model/_model.dart';
import 'package:portrai/src/feature/project/data/repository/cache_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

@register
class RemoteProjectRepositoryImpl implements ProjectRepository {
  RemoteProjectRepositoryImpl(
    this._firestoreController,
    this._appLocale,
    @Inject(CacheProjectRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final AppLocale _appLocale;
  final ProjectRepository _cacheDelegateRepository;
  final ProjectMapper _mapper;
  final LogReporter _logReporter;

  @override
  Future<void> cacheProject(ProjectEntity project) {
    return _cacheDelegateRepository.cacheProject(project);
  }

  @override
  Future<List<ProjectEntity>> getProjects() async {
    try {
      final cachedProjects = await _cacheDelegateRepository.getProjects();
      if (cachedProjects.isNotEmpty) {
        return cachedProjects;
      }
    } on ProjectNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from remote
    } on ProjectCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting projects, loading from remote instead.',
      );
    }

    final projectList = await _loadProjectsFromRemote();

    await _cacheProjectsSafely(projectList);

    return projectList;
  }

  @override
  Future<ProjectEntity> getProject(String id) async {
    try {
      return await _cacheDelegateRepository.getProject(id);
    } on ProjectNotFoundException {
      // If not in cache, load all from remote and try again
      _logReporter.debug('Project $id not found in cache, loading from remote');
    } on ProjectCacheException catch (_) {
      _logReporter.error(
        'Cache error while getting project, loading from remote instead.',
      );
    }

    final projectList = await _loadProjectsFromRemote();
    await _cacheProjectsSafely(projectList);

    // Find the project in the loaded list
    final project = projectList.firstWhere(
      (p) => p.id == id,
      orElse: () => throw ProjectNotFoundException(
        cause: 'Project with id $id not found in Firestore',
      ),
    );

    return project;
  }

  Future<List<ProjectEntity>> _loadProjectsFromRemote() async {
    try {
      final locale = _appLocale.languageCode;
      final projectJson = await _firestoreController.getDocumentFromCollection(
        'projects',
        locale,
      );

      if (projectJson == null) {
        throw const ProjectNotFoundException(
          cause: 'Projects document not found in Firestore',
        );
      }

      try {
        final projectsJson = projectJson['projects'] as List<dynamic>;
        final projectList = projectsJson.map((json) {
          final projectMap = json as Map<String, dynamic>;

          projectMap['locale'] = locale;

          final projectModel = ProjectModel.fromJson(projectMap);
          return _mapper.to(projectModel);
        }).toList();

        return projectList;
      } catch (e, st) {
        throw ProjectParsingException(
          cause: 'Failed to parse projects from Firestore: $e',
          stackTrace: st,
        );
      }
    } on ProjectNotFoundException {
      rethrow;
    } on ProjectParsingException {
      rethrow;
    } on FirestoreDocumentNotFoundException catch (e, st) {
      throw ProjectNotFoundException(cause: e, stackTrace: st);
    } on FirestorePermissionDeniedException catch (e, st) {
      throw ProjectUnauthorizedException(cause: e, stackTrace: st);
    } on FirestoreTimeoutException catch (e, st) {
      throw ProjectNetworkException(cause: e, stackTrace: st);
    } on FirestoreInvalidDataException catch (e, st) {
      throw ProjectParsingException(cause: e, stackTrace: st);
    } on FirestoreQuotaExceededException catch (e, st) {
      throw ProjectNetworkException(cause: e, stackTrace: st);
    } catch (e, st) {
      throw ProjectParsingException(
        cause: 'Unexpected error while loading projects: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheProjectsSafely(List<ProjectEntity> projectList) async {
    try {
      for (final project in projectList) {
        await cacheProject(project);
      }
    } catch (_) {
      _logReporter.error(
        'Failed to cache projects from remote, continuing without caching.',
      );
    }
  }
}
