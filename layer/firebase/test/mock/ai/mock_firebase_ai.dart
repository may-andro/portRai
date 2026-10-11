import 'package:firebase_ai/firebase_ai.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAI extends Mock implements FirebaseAI {}

extension MockFirebaseAIStub on MockFirebaseAI {
  void stubGenerativeModel({
    required String model,
    required GenerationConfig generationConfig,
    required GenerativeModel result,
    Content? systemInstruction,
    List<SafetySetting>? safetySettings,
  }) {
    when(
      () => generativeModel(
        model: model,
        generationConfig: generationConfig,
        systemInstruction: systemInstruction,
        safetySettings: safetySettings,
        httpClient: any(named: 'httpClient'),
      ),
    ).thenReturn(result);
  }
}
