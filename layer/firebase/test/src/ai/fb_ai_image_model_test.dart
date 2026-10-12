import 'dart:typed_data';

import 'package:firebase/firebase.dart';
import 'package:firebase_ai/firebase_ai.dart'
    show
        BlockReason,
        Candidate,
        FinishReason,
        GenerateContentResponse,
        Part,
        PromptFeedback;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/ai/mock_ai_model_client.dart';

GenerateContentResponse imageResponse(
  List<Part> parts, {
  FinishReason? finishReason = FinishReason.stop,
}) => GenerateContentResponse([
  Candidate(Content.model(parts), null, null, finishReason, null),
], null);

void main() {
  setUpAll(() {
    registerFallbackValue(<Content>[]);
  });

  final bytes = Uint8List.fromList([1, 2, 3]);

  test('should return image when response contains image data', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(
        imageResponse([
          const TextPart('Done'),
          InlineDataPart('image/png', bytes),
        ]),
      );

    final image = await FbAiImageModel(
      sdk,
    ).generateImage([Content.text('Draw')]);

    expect(image.bytes, bytes);
    expect(image.mimeType, 'image/png');
  });

  test('should throw empty response when no image is returned', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(imageResponse([const TextPart('Sorry')]));

    await expectLater(
      FbAiImageModel(sdk).generateImage([Content.text('Draw')]),
      throwsA(isA<AiEmptyResponseException>()),
    );
  });

  test('should throw blocked when finish reason is safety', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(
        imageResponse([
          InlineDataPart('image/png', bytes),
        ], finishReason: FinishReason.safety),
      );

    await expectLater(
      FbAiImageModel(sdk).generateImage([Content.text('Draw')]),
      throwsA(isA<AiBlockedResponseException>()),
    );
  });

  test('should throw blocked when prompt is blocked', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(
        GenerateContentResponse(
          const [],
          PromptFeedback(BlockReason.safety, null, const []),
        ),
      );

    await expectLater(
      FbAiImageModel(sdk).generateImage([Content.text('Draw')]),
      throwsA(isA<AiBlockedResponseException>()),
    );
  });

  test('should throw incomplete when finish reason is max tokens', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(
        imageResponse([
          InlineDataPart('image/png', bytes),
        ], finishReason: FinishReason.maxTokens),
      );

    await expectLater(
      FbAiImageModel(sdk).generateImage([Content.text('Draw')]),
      throwsA(isA<AiIncompleteResponseException>()),
    );
  });

  test('should throw invalid input when contents are empty', () async {
    final sdk = MockAiModelClient();

    await expectLater(
      FbAiImageModel(sdk).generateImage(const []),
      throwsA(isA<AiInvalidInputException>()),
    );
    verifyNever(() => sdk.generateContent(any()));
  });

  test('should throw state error when model is closed', () async {
    final sdk = MockAiModelClient();
    final model = FbAiImageModel(sdk)..close();

    await expectLater(
      model.generateImage([Content.text('Draw')]),
      throwsStateError,
    );
    verify(sdk.close).called(1);
  });
}
