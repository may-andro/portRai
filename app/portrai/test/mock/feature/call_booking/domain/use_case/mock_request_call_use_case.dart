import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockRequestCallUseCase extends Mock implements RequestCallUseCase {}

extension MockRequestCallUseCaseStub on MockRequestCallUseCase {
  /// Stubs `call(param)` to return [result] for any [RequestCallParam].
  void stubCall(Either<RequestCallFailure, String> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
