import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetCallSlotsUseCase extends Mock implements GetCallSlotsUseCase {}

extension MockGetCallSlotsUseCaseStub on MockGetCallSlotsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetCallSlotsFailure, CallSlotsEntity> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
