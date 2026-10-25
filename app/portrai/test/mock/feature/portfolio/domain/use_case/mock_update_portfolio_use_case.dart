import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockUpdatePortfolioUseCase extends Mock
    implements UpdatePortfolioUseCase {}

extension MockUpdatePortfolioUseCaseStub on MockUpdatePortfolioUseCase {
  void stubCall(Either<UpdatePortfolioFailure, Set<PortfolioSection>> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
