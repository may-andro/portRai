import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockIsAppUpdateRequiredUseCase extends Mock
    implements IsAppUpdateRequiredUseCase {}

extension MockIsAppUpdateRequiredUseCaseStub on MockIsAppUpdateRequiredUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<IsAppUpdateRequiredFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
