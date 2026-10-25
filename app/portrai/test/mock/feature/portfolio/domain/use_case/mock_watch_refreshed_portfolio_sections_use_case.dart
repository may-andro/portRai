import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockWatchRefreshedPortfolioSectionsUseCase extends Mock
    implements WatchRefreshedPortfolioSectionsUseCase {}

extension MockWatchRefreshedPortfolioSectionsUseCaseStub
    on MockWatchRefreshedPortfolioSectionsUseCase {
  void stubCall(
    Stream<
      Either<WatchRefreshedPortfolioSectionsFailure, Set<PortfolioSection>>
    >
    stream,
  ) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
