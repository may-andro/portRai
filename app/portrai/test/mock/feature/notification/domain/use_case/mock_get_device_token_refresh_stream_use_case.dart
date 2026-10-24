import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

class MockGetDeviceTokenRefreshStreamUseCase extends Mock
    implements GetDeviceTokenRefreshStreamUseCase {}

extension MockGetDeviceTokenRefreshStreamUseCaseStub
    on MockGetDeviceTokenRefreshStreamUseCase {
  void stubCall(Stream<String> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
