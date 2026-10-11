import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import '../mock/ai/mock_firebase_app.dart';

GenerativeModel createAiTestModel({Client? httpClient}) {
  final app = MockFirebaseApp()..stubOptions();
  return FirebaseAI.googleAI(app: app).generativeModel(
    model: 'test-model',
    httpClient:
        httpClient ??
        MockClient((_) async => throw StateError('No requests expected')),
  );
}
