import 'package:design_system/design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:use_case/use_case.dart';

class MockSetDesignSystemUseCase extends Mock
    implements SetDesignSystemUseCase {}

extension MockSetDesignSystemUseCaseStub on MockSetDesignSystemUseCase {
  void registerFallbacks() => registerFallbackValue(DesignSystem.hogmanay);

  void stubCall(Either<SetDesignSystemFailure, void> setDesignSystemEither) {
    when(() => this(any())).thenAnswer((_) => setDesignSystemEither);
  }
}
