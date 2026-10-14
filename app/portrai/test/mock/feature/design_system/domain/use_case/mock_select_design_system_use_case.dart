import 'package:design_system/design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:use_case/use_case.dart';

class MockSelectDesignSystemUseCase extends Mock
    implements SelectDesignSystemUseCase {}

extension MockSelectDesignSystemUseCaseStub on MockSelectDesignSystemUseCase {
  void stubCall(DesignSystem designSystem) {
    when(
      () => this(),
    ).thenAnswer((_) => Right<NoFailure, DesignSystem>(designSystem));
  }
}
