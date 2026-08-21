import 'package:portrai/src/feature/project/domain/entity/_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();

  Future<ProjectEntity> getProject(String id);

  Future<void> cacheProject(ProjectEntity project);
}
