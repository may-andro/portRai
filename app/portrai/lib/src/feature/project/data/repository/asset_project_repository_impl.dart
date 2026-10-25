import 'dart:convert';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/project/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/project/data/model/_model.dart';
import 'package:portrai/src/feature/project/data/repository/cache_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

@register
class AssetProjectRepositoryImpl implements ProjectRepository {
  AssetProjectRepositoryImpl(
    this._appLocale,
    @Inject(CacheProjectRepositoryImpl) this._cacheDelegateRepository,
    this._mapper,
    this._logReporter,
    this._errorReporter,
    this._getAssetSourceUseCase,
  );

  final AppLocale _appLocale;
  final ProjectRepository _cacheDelegateRepository;
  final ProjectMapper _mapper;
  final LogReporter _logReporter;
  final ErrorReporter _errorReporter;
  final GetAssetSourceUseCase _getAssetSourceUseCase;
  static const _tag = 'AssetProjectRepositoryImpl';

  @override
  Future<void> cacheProjects(List<ProjectEntity> projects) {
    return _cacheDelegateRepository.cacheProjects(projects);
  }

  /// The bundled projects do not change while the app runs.
  @override
  Future<void> refreshProjects() async {}

  @override
  Future<List<ProjectEntity>> getProjects() async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) return await _loadProjectsFromAssets(source);

    try {
      final cachedProjects = await _cacheDelegateRepository.getProjects();
      if (cachedProjects.isNotEmpty) {
        return cachedProjects;
      }
    } on ProjectNotFoundException catch (_) {
      // Cache is empty for current locale - fall through to load from assets
    } on ProjectCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting projects: ${e.cause}',
        tag: _tag,
        stacktrace: stackTrace,
      );
    }

    final projectList = await _loadProjectsFromAssets(source);

    await _cacheProjectsSafely(projectList);

    return projectList;
  }

  @override
  Future<ProjectEntity> getProject(String id) async {
    final source = (await _getAssetSourceUseCase()).right;
    if (source.isTemplate) {
      final projects = await _loadProjectsFromAssets(source);
      return projects.firstWhere(
        (p) => p.id == id,
        orElse: () => throw ProjectNotFoundException(
          cause: 'Project with id $id not found in assets',
        ),
      );
    }

    try {
      return await _cacheDelegateRepository.getProject(id);
    } on ProjectNotFoundException {
      // If not in cache, load all from assets and try again
      _logReporter.debug(
        'Project $id not found in cache, loading from assets',
        tag: _tag,
      );
    } on ProjectCacheException catch (e, stackTrace) {
      _logReporter.error(
        'Cache error while getting project: ${e.cause}',
        tag: _tag,
        stacktrace: stackTrace,
      );
    }

    final projectList = await _loadProjectsFromAssets(source);
    await _cacheProjectsSafely(projectList);

    // Find the project in the loaded list
    final project = projectList.firstWhere(
      (p) => p.id == id,
      orElse: () => throw ProjectNotFoundException(
        cause: 'Project with id $id not found in assets',
      ),
    );

    return project;
  }

  Future<List<ProjectEntity>> _loadProjectsFromAssets(
    AssetSource source,
  ) async {
    try {
      final locale = _appLocale.languageCode;
      final jsonString = await rootBundle.loadString(
        source.assetPath('projects'),
      );
      final localeProjectJson =
          (jsonDecode(jsonString) as Map<String, dynamic>)[locale]
              as Map<String, dynamic>;

      final projectsJson = localeProjectJson['projects'] as List<dynamic>;

      return projectsJson.map((json) {
        final projectMap = json as Map<String, dynamic>;

        projectMap['locale'] = locale;

        return _mapper.to(ProjectModel.fromJson(projectMap));
      }).toList();
    } catch (e, st) {
      throw ProjectParsingException(
        cause: 'Failed to load projects from assets: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _cacheProjectsSafely(List<ProjectEntity> projectList) async {
    try {
      await cacheProjects(projectList);
    } on ProjectCacheException catch (exception, stackTrace) {
      // Loading still succeeds without the cache, so the failure is reported
      // instead of thrown.
      await _errorReporter.reportError(
        exception: exception,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }
}
