import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:use_case/use_case.dart';

class MockResetDesignSystemUseCase extends Mock
    implements ResetDesignSystemUseCase {}

extension MockResetDesignSystemUseCaseStub on MockResetDesignSystemUseCase {
  void stubCall(
    Either<ResetDesignSystemFailure, void> resetDesignSystemEither,
  ) {
    when(() => this()).thenAnswer((_) => resetDesignSystemEither);
  }
}
