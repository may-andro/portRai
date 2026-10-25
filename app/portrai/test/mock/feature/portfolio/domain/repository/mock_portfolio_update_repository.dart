import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';

class MockPortfolioUpdateRepository extends Mock
    implements PortfolioUpdateRepository {}

extension MockPortfolioUpdateRepositoryStub on MockPortfolioUpdateRepository {
  void stubGetChangeTimes(Map<PortfolioSection, DateTime> changeTimes) {
    when(getChangeTimes).thenAnswer((_) async => changeTimes);
  }

  void stubGetChangeTimesThrows(Object error) {
    when(getChangeTimes).thenThrow(error);
  }

  void stubGetAppliedChangeTimes(Map<PortfolioSection, DateTime> changeTimes) {
    when(getAppliedChangeTimes).thenAnswer((_) async => changeTimes);
  }

  void stubSetAppliedChangeTime() {
    when(() => setAppliedChangeTime(any(), any())).thenAnswer((_) async {});
  }

  void stubReportRefreshedSections() {
    when(() => reportRefreshedSections(any())).thenReturn(null);
  }

  void stubRefreshedSections(Stream<Set<PortfolioSection>> sections) {
    when(() => refreshedSections).thenAnswer((_) => sections);
  }
}
