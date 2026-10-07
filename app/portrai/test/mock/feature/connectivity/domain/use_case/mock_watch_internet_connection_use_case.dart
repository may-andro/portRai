import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockWatchInternetConnectionUseCase extends Mock
    implements WatchInternetConnectionUseCase {}

extension MockWatchInternetConnectionUseCaseStub
    on MockWatchInternetConnectionUseCase {
  void stubCall(Stream<Either<WatchInternetConnectionFailure, bool>> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
