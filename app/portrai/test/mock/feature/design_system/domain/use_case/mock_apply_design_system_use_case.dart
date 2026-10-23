import 'package:design_system/design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:use_case/use_case.dart';

class MockApplyDesignSystemUseCase extends Mock
    implements ApplyDesignSystemUseCase {}

extension MockApplyDesignSystemUseCaseStub on MockApplyDesignSystemUseCase {
  void registerFallbacks() => registerFallbackValue(DesignSystem.hogmanay);

  void stubCall(
    Either<ApplyDesignSystemFailure, void> applyDesignSystemEither,
  ) {
    when(() => this(any())).thenAnswer((_) => applyDesignSystemEither);
  }
}
