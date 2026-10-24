import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

class MockGetOpenedPushMessageStreamUseCase extends Mock
    implements GetOpenedPushMessageStreamUseCase {}

extension MockGetOpenedPushMessageStreamUseCaseStub
    on MockGetOpenedPushMessageStreamUseCase {
  void stubCall(Stream<PushMessageEntity> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
