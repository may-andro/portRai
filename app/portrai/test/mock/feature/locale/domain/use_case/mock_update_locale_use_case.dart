import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockUpdateLocaleUseCase extends Mock implements UpdateLocaleUseCase {}

extension MockUpdateLocaleUseCaseStub on MockUpdateLocaleUseCase {
  void stubCall({
    required AppLocale locale,
    required Either<UpdateLocaleFailure, void> result,
  }) {
    when(() => this(locale)).thenAnswer((_) => result);
  }
}
