import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockWatchForegroundPushMessagesUseCase extends Mock
    implements WatchForegroundPushMessagesUseCase {}

extension MockWatchForegroundPushMessagesUseCaseStub
    on MockWatchForegroundPushMessagesUseCase {
  void stubCall(
    Stream<Either<WatchForegroundPushMessagesFailure, PushMessageEntity>>
    stream,
  ) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
