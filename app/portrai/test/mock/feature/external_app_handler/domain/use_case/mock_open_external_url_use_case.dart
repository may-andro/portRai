import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockOpenExternalUrlUseCase extends Mock
    implements OpenExternalUrlUseCase {}

extension MockOpenExternalUrlUseCaseStub on MockOpenExternalUrlUseCase {
  /// Stubs `call(param)` to return [result] for any [OpenExternalUrlParam].
  void stubCall(Either<OpenExternalUrlFailure, bool> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
