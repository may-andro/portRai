import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

extension MockProjectRepositoryStub on MockProjectRepository {
  void stubCacheProjects(List<ProjectEntity> projects) {
    when(() => cacheProjects(projects)).thenAnswer((_) async {});
  }

  void stubCacheProjectsThrows({
    required List<ProjectEntity> projects,
    required Object error,
  }) {
    when(() => cacheProjects(projects)).thenThrow(error);
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

  void stubRefreshProjects() {
    when(refreshProjects).thenAnswer((_) async {});
  }

  void stubRefreshProjectsThrows(Object error) {
    when(refreshProjects).thenThrow(error);
  }
}
