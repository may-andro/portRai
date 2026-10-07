import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

extension MockProjectRepositoryStub on MockProjectRepository {
  void stubCacheProject(ProjectEntity project) {
    when(() => cacheProject(project)).thenAnswer((_) async {});
  }

  void stubCacheProjectThrows({
    required ProjectEntity project,
    required Object error,
  }) {
    when(() => cacheProject(project)).thenThrow(error);
  }

  void stubGetProject({required String id, required ProjectEntity project}) {
    when(() => getProject(id)).thenAnswer((_) async => project);
  }

  void stubGetProjectThrows({required String id, required Object error}) {
    when(() => getProject(id)).thenThrow(error);
  }

  void stubGetProjects(List<ProjectEntity> projects) {
    when(() => getProjects()).thenAnswer((_) async => projects);
  }

  void stubGetProjectsThrows(Object error) {
    when(() => getProjects()).thenThrow(error);
  }
}
