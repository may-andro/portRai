import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';

class MockConnectivityRepository extends Mock
    implements ConnectivityRepository {}

extension MockConnectivityRepositoryStub on MockConnectivityRepository {
  void stubIsConnected(bool value) {
    when(isConnected).thenAnswer((_) async => value);
  }

  void stubWatchConnection(Stream<bool> stream) {
    when(watchConnection).thenAnswer((_) => stream);
  }
}
