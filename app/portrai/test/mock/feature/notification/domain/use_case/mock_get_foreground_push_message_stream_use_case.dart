import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

class MockGetForegroundPushMessageStreamUseCase extends Mock
    implements GetForegroundPushMessageStreamUseCase {}

extension MockGetForegroundPushMessageStreamUseCaseStub
    on MockGetForegroundPushMessageStreamUseCase {
  void stubCall(Stream<PushMessageEntity> stream) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
