import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockSyncNotificationsUseCase extends Mock
    implements SyncNotificationsUseCase {}

extension MockSyncNotificationsUseCaseStub on MockSyncNotificationsUseCase {
  void stubCall() {
    when(() => this(any())).thenAnswer((_) => const Right(null));
  }
}
