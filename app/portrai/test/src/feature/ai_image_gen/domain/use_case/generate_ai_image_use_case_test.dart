import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/_domain.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/ai_image_gen/domain/repository/mock_ai_image_repository.dart';
import '../../../../../mock/feature/ai_image_gen/domain/use_case/mock_resolve_ai_image_request_settings_use_case.dart';
import '../../../../../mock/feature/ai_rate_limit/domain/use_case/mock_consume_ai_request_quota_use_case.dart';
import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';

void main() {
  group('GenerateAiImageUseCase', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockAiImageRepository repository;
    late MockResolveAiImageRequestSettingsUseCase resolveSettingsUseCase;
    late MockConsumeAiRequestQuotaUseCase consumeAiRequestQuotaUseCase;
    late GenerateAiImageUseCase useCase;

    final image = AiImageEntity(
      bytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/png',
    );
    const param = GenerateAiImageParam(
      sourceImageUrl: 'https://example.com/a.png',
    );

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
      repository = MockAiImageRepository()..stubGetCachedAiImage(null);
      consumeAiRequestQuotaUseCase = MockConsumeAiRequestQuotaUseCase()
        ..stubCall(const Right(null));
      resolveSettingsUseCase = MockResolveAiImageRequestSettingsUseCase()
        ..stubCall(
          const AiImageRequestSettings(prompt: 'prompt', model: 'model'),
        );
      useCase = GenerateAiImageUseCase(
        isFeatureEnabledUseCase,
        repository,
        resolveSettingsUseCase,
        consumeAiRequestQuotaUseCase,
      );
    });

    void stubFlag(Either<IsFeatureEnabledFailure, bool> result) {
      isFeatureEnabledUseCase.stubCall(
        definition: AiImageGenFeatureFlags.aiImageGeneration,
        result: result,
      );
    }

    test(
      'should return image generated with the resolved settings when the flag is enabled',
      () async {
        stubFlag(const Right(true));
        repository.stubGenerateAiImage(image);

        final result = await useCase(param);

        expect(result.right, image);
        verify(
          () => repository.generateAiImage(
            sourceImageUrl: 'https://example.com/a.png',
            prompt: 'prompt',
            model: 'model',
          ),
        ).called(1);
      },
    );

    test(
      'should return feature disabled failure when the flag is off',
      () async {
        stubFlag(const Right(false));

        final result = await useCase(param);

        expect(result.left, isA<AiImageFeatureDisabledFailure>());
        verifyNever(
          () => repository.generateAiImage(
            sourceImageUrl: any(named: 'sourceImageUrl'),
            prompt: any(named: 'prompt'),
            model: any(named: 'model'),
          ),
        );
      },
    );

    test(
      'should return unavailable failure when the flag lookup fails',
      () async {
        stubFlag(const Left(FeatureFlagUnknownFailure()));

        final result = await useCase(param);

        expect(result.left, isA<AiImageUnavailableFailure>());
      },
    );

    test(
      'should return source failure when the source image is invalid',
      () async {
        stubFlag(const Right(true));
        repository.stubGenerateAiImageError(const AiImageSourceException());

        final result = await useCase(param);

        expect(result.left, isA<AiImageSourceFailure>());
      },
    );

    test('should return generation failure when generation throws', () async {
      stubFlag(const Right(true));
      repository.stubGenerateAiImageError(const AiImageGenerationException());

      final result = await useCase(param);

      expect(result.left, isA<AiImageGenerationFailure>());
    });

    test(
      'should return unknown failure when an unexpected error occurs',
      () async {
        stubFlag(const Right(true));
        repository.stubGenerateAiImageError(StateError('boom'));

        final result = await useCase(param);

        expect(result.left, isA<AiImageUnknownFailure>());
      },
    );

    test(
      'should return the cached image without using the AI budget when one is cached',
      () async {
        stubFlag(const Right(true));
        repository.stubGetCachedAiImage(image);

        final generateAiImageEither = await useCase(param);

        expect(generateAiImageEither.right, image);
        verifyNever(() => consumeAiRequestQuotaUseCase());
        verifyNever(
          () => repository.generateAiImage(
            sourceImageUrl: any(named: 'sourceImageUrl'),
            prompt: any(named: 'prompt'),
            model: any(named: 'model'),
          ),
        );
      },
    );

    test(
      'should return quota exceeded failure without generating when the AI budget is used up',
      () async {
        stubFlag(const Right(true));
        consumeAiRequestQuotaUseCase.stubCall(
          const Left(AiRequestQuotaExceededFailure()),
        );

        final generateAiImageEither = await useCase(param);

        expect(generateAiImageEither.left, isA<AiImageQuotaExceededFailure>());
        verifyNever(
          () => repository.generateAiImage(
            sourceImageUrl: any(named: 'sourceImageUrl'),
            prompt: any(named: 'prompt'),
            model: any(named: 'model'),
          ),
        );
      },
    );

    test(
      'should still generate when the AI request log cannot be read',
      () async {
        stubFlag(const Right(true));
        consumeAiRequestQuotaUseCase.stubCall(
          const Left(AiRequestQuotaCacheFailure()),
        );
        repository.stubGenerateAiImage(image);

        final generateAiImageEither = await useCase(param);

        expect(generateAiImageEither.right, image);
      },
    );
  });
}
