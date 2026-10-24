import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockResetDeviceTokenUseCase extends Mock
    implements ResetDeviceTokenUseCase {}

extension MockResetDeviceTokenUseCaseStub on MockResetDeviceTokenUseCase {
  void stubCall() {
    when(() => this()).thenAnswer((_) => const Right(null));
  }
}
