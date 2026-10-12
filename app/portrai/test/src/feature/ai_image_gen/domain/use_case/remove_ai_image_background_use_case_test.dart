import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';

import '../../../../../mock/feature/ai_image_gen/domain/repository/mock_ai_image_processing_repository.dart';

void main() {
  final image = AiImageEntity(
    bytes: Uint8List.fromList([1, 2, 3]),
    mimeType: 'image/jpeg',
  );
  final transparent = AiImageEntity(
    bytes: Uint8List.fromList([4, 5]),
    mimeType: 'image/png',
  );

  late MockAiImageProcessingRepository repository;
  late RemoveAiImageBackgroundUseCase useCase;

  setUpAll(() => registerFallbackValue(image));

  setUp(() {
    repository = MockAiImageProcessingRepository();
    useCase = RemoveAiImageBackgroundUseCase(repository);
  });

  test('should return the processed image when processing succeeds', () async {
    repository.stubRemoveBackground(transparent);

    final result = await useCase(image);

    expect(result.right, transparent);
  });

  test(
    'should return processing failure when the repository throws a processing exception',
    () async {
      repository.stubRemoveBackgroundError(const AiImageProcessingException());

      final result = await useCase(image);

      expect(result.left, isA<AiImageProcessingFailure>());
    },
  );

  test(
    'should return unknown failure when the repository throws an unexpected error',
    () async {
      repository.stubRemoveBackgroundError(StateError('boom'));

      final result = await useCase(image);

      expect(result.left, isA<RemoveAiImageBackgroundUnknownFailure>());
    },
  );
}
