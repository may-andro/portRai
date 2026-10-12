import 'package:firebase/firebase.dart';
import 'package:firebase_ai/firebase_ai.dart'
    show InvalidApiKey, ResponseModalities;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/ai/mock_firebase_ai.dart';
import '../../util/ai_test_model.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      MockClient((_) async => throw StateError('No requests expected')),
    );
  });
  test('should forward configuration when a text model is created', () {
    final sdk = MockFirebaseAI();
    final model = createAiTestModel();
    final config = GenerationConfig(maxOutputTokens: 1024, temperature: 0.2);
    sdk.stubGenerativeModel(
      model: 'configured-model',
      generationConfig: config,
      result: model,
    );

    final result = FbAiController(
      sdk,
    ).createTextModel(model: ' configured-model ', generationConfig: config);
    addTearDown(result.close);

    expect(result, isA<FbAiTextModel>());
    verify(
      () => sdk.generativeModel(
        model: 'configured-model',
        generationConfig: config,
        httpClient: any(named: 'httpClient'),
      ),
    ).called(1);
  });

  test('should forward instructions and safety settings when supplied', () {
    final sdk = MockFirebaseAI();
    final model = createAiTestModel();
    final config = GenerationConfig(maxOutputTokens: 1024);
    final safety = [
      SafetySetting(
        HarmCategory.dangerousContent,
        HarmBlockThreshold.medium,
        HarmBlockMethod.probability,
      ),
    ];
    registerFallbackValue(Content.system('fallback'));
    when(
      () => sdk.generativeModel(
        model: 'configured-model',
        generationConfig: config,
        systemInstruction: any(named: 'systemInstruction'),
        safetySettings: safety,
        httpClient: any(named: 'httpClient'),
      ),
    ).thenReturn(model);

    final result = FbAiController(sdk).createTextModel(
      model: 'configured-model',
      generationConfig: config,
      systemInstruction: 'Use supplied facts only.',
      safetySettings: safety,
    );
    addTearDown(result.close);

    final instruction =
        verify(
              () => sdk.generativeModel(
                model: 'configured-model',
                generationConfig: config,
                systemInstruction: captureAny(named: 'systemInstruction'),
                safetySettings: safety,
                httpClient: any(named: 'httpClient'),
              ),
            ).captured.single
            as Content;
    expect(
      instruction.toJson(),
      Content.system('Use supplied facts only.').toJson(),
    );
  });

  for (final (name, config) in [
    ('empty model name', GenerationConfig(maxOutputTokens: 100)),
    ('missing token limit', GenerationConfig()),
    ('zero token limit', GenerationConfig(maxOutputTokens: 0)),
    ('negative token limit', GenerationConfig(maxOutputTokens: -1)),
    (
      'multiple candidates',
      GenerationConfig(maxOutputTokens: 100, candidateCount: 2),
    ),
  ]) {
    test('should reject configuration when it has $name', () {
      final sdk = MockFirebaseAI();
      expect(
        () => FbAiController(sdk).createTextModel(
          model: name == 'empty model name' ? ' ' : 'configured-model',
          generationConfig: config,
        ),
        throwsA(isA<AiInvalidInputException>()),
      );
      verifyZeroInteractions(sdk);
    });
  }

  test(
    'should propagate unexpected errors when model creation has a programming error',
    () {
      final sdk = MockFirebaseAI();
      final config = GenerationConfig(maxOutputTokens: 1024);
      when(
        () => sdk.generativeModel(
          model: 'configured-model',
          generationConfig: config,
          httpClient: any(named: 'httpClient'),
        ),
      ).thenThrow(ArgumentError('Unexpected programming error'));

      expect(
        () => FbAiController(
          sdk,
        ).createTextModel(model: 'configured-model', generationConfig: config),
        throwsArgumentError,
      );
    },
  );

  test(
    'should map configuration errors when the SDK rejects initialization',
    () {
      final sdk = MockFirebaseAI();
      final config = GenerationConfig(maxOutputTokens: 1024);
      when(
        () => sdk.generativeModel(
          model: 'configured-model',
          generationConfig: config,
          httpClient: any(named: 'httpClient'),
        ),
      ).thenThrow(InvalidApiKey('Invalid'));
      expect(
        () => FbAiController(
          sdk,
        ).createTextModel(model: 'configured-model', generationConfig: config),
        throwsA(isA<AiConfigurationException>()),
      );
    },
  );

  test('should request image modalities when an image model is created', () {
    final sdk = MockFirebaseAI();
    final model = createAiTestModel();
    when(
      () => sdk.generativeModel(
        model: 'image-model',
        generationConfig: any(named: 'generationConfig'),
        httpClient: any(named: 'httpClient'),
      ),
    ).thenReturn(model);

    final result = FbAiController(sdk).createImageModel(model: ' image-model ');
    addTearDown(result.close);

    final config =
        verify(
              () => sdk.generativeModel(
                model: 'image-model',
                generationConfig: captureAny(named: 'generationConfig'),
                httpClient: any(named: 'httpClient'),
              ),
            ).captured.single
            as GenerationConfig;
    expect(config.candidateCount, 1);
    expect(config.responseModalities, [
      ResponseModalities.text,
      ResponseModalities.image,
    ]);
    expect(result, isA<FbAiImageModel>());
  });

  test('should throw invalid input when image model name is blank', () {
    expect(
      () => FbAiController(MockFirebaseAI()).createImageModel(model: ' '),
      throwsA(isA<AiInvalidInputException>()),
    );
  });
}
