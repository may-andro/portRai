import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbAnalyticsController extends Mock implements FbAnalyticsController {
  void mockSendLogEvent() {
    when(
      () => sendLogEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
  }
}
