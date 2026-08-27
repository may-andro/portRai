import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetAppStoreUrlUseCase extends Mock implements GetAppStoreUrlUseCase {}

extension MockGetAppStoreUrlUseCaseStub on MockGetAppStoreUrlUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(Either<GetAppStoreUrlFailure, Uri> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
