import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetInitialPushMessageUseCase extends Mock
    implements GetInitialPushMessageUseCase {}

extension MockGetInitialPushMessageUseCaseStub
    on MockGetInitialPushMessageUseCase {
  void stubCall(PushMessageEntity? message) {
    when(() => this()).thenAnswer((_) => Right(message));
  }
}
