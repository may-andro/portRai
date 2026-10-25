import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';

class MockPortfolioSyncRepository extends Mock
    implements PortfolioSyncRepository {}

extension MockPortfolioSyncRepositoryStub on MockPortfolioSyncRepository {
  void stubGetChangeTimes(Map<PortfolioSection, DateTime> changeTimes) {
    when(getChangeTimes).thenAnswer((_) async => changeTimes);
  }

  void stubGetChangeTimesThrows(Object error) {
    when(getChangeTimes).thenThrow(error);
  }

  void stubGetSyncedChangeTimes(Map<PortfolioSection, DateTime> changeTimes) {
    when(getSyncedChangeTimes).thenAnswer((_) async => changeTimes);
  }

  void stubSetSyncedChangeTime() {
    when(() => setSyncedChangeTime(any(), any())).thenAnswer((_) async {});
  }

  void stubReportRefreshedSections() {
    when(() => reportRefreshedSections(any())).thenReturn(null);
  }

  void stubRefreshedSections(Stream<Set<PortfolioSection>> sections) {
    when(() => refreshedSections).thenAnswer((_) => sections);
  }
}
