import 'package:firebase/src/ai/ai_model_client.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:mocktail/mocktail.dart';

class MockAiModelClient extends Mock implements AiModelClient {}

extension MockAiModelClientStub on MockAiModelClient {
  void stubGenerateContent(GenerateContentResponse response) {
    when(() => generateContent(any())).thenAnswer((_) async => response);
  }

  void stubGenerateContentError(Object error, StackTrace stackTrace) {
    when(
      () => generateContent(any()),
    ).thenAnswer((_) => Future.error(error, stackTrace));
  }

  void stubGenerateContentStream(Stream<GenerateContentResponse> responses) {
    when(() => generateContentStream(any())).thenAnswer((_) => responses);
  }
}
