import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetLocaleUseCase extends Mock implements GetLocaleUseCase {}

extension MockGetLocaleUseCaseStub on MockGetLocaleUseCase {
  void stubCall(Either<GetLocaleFailure, AppLocale> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
