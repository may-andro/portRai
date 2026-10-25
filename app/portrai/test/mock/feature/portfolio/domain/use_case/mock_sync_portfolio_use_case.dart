import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSyncPortfolioUseCase extends Mock implements SyncPortfolioUseCase {}

extension MockSyncPortfolioUseCaseStub on MockSyncPortfolioUseCase {
  void stubCall(Either<SyncPortfolioFailure, Set<PortfolioSection>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
