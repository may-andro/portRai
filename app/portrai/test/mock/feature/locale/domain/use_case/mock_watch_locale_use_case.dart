import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/use_case/watch_locale_use_case.dart';
import 'package:use_case/use_case.dart';

class MockWatchLocaleUseCase extends Mock implements WatchLocaleUseCase {}

extension MockWatchLocaleUseCaseStub on MockWatchLocaleUseCase {
  void stubCall(Stream<Either<WatchLocaleFailure, AppLocale>> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
