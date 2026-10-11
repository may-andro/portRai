import 'package:firebase/src/ai/ai_exception.dart';
import 'package:firebase/src/ai/ai_model_client.dart';
import 'package:firebase/src/ai/fb_ai_text_model.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

class FbAiController {
  FbAiController(this._firebaseAi);

  final FirebaseAI _firebaseAi;

  FbAiTextModel createTextModel({
    required String model,
    required GenerationConfig generationConfig,
    String? systemInstruction,
    List<SafetySetting>? safetySettings,
  }) {
    final maxOutputTokens = generationConfig.maxOutputTokens;
    if (model.trim().isEmpty ||
        maxOutputTokens == null ||
        maxOutputTokens <= 0 ||
        (generationConfig.candidateCount != null &&
            generationConfig.candidateCount != 1)) {
      throw AiInvalidInputException(
        ArgumentError(
          'A model name, positive output token limit, and single candidate are required.',
        ),
        StackTrace.current,
      );
    }

    final client = Client();
    var transferred = false;
    try {
      final sdkModel = _firebaseAi.generativeModel(
        model: model.trim(),
        generationConfig: generationConfig,
        systemInstruction: systemInstruction == null
            ? null
            : Content.system(systemInstruction),
        safetySettings: safetySettings,
        httpClient: client,
      );
      final result = FbAiTextModel(FirebaseAiModelClient(sdkModel, client));
      transferred = true;
      return result;
    } on FirebaseAIException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on FirebaseAISdkException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } finally {
      if (!transferred) client.close();
    }
  }
}
