import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockWatchOpenedPushMessagesUseCase extends Mock
    implements WatchOpenedPushMessagesUseCase {}

extension MockWatchOpenedPushMessagesUseCaseStub
    on MockWatchOpenedPushMessagesUseCase {
  void stubCall(
    Stream<Either<WatchOpenedPushMessagesFailure, PushMessageEntity>> stream,
  ) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
