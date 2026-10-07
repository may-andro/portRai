import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetPortfolioUseCase extends Mock implements GetPortfolioUseCase {}

extension MockGetPortfolioUseCaseStub on MockGetPortfolioUseCase {
  void stubCall(Either<GetPortfolioFailure, PortfolioEntity> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
