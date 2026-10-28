import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

void main() {
  group('PortraiAppConfigMapper', () {
    const mapper = PortraiAppConfigMapper(
      AiImageAppConfigMapper(),
      AiRateLimitAppConfigMapper(),
    );

    test('should map the model to an entity when the AI image is set', () {
      final entity = mapper.to(
        const PortraiAppConfigModel(
          minimumRequiredAppVersion: '1.2.3',
          aiImage: AiImageAppConfigModel(model: 'model', style: 'naruto'),
        ),
      );

      expect(
        entity,
        const PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.2.3',
          aiImage: AiImageAppConfig(model: 'model', style: 'naruto'),
        ),
      );
    });

    test('should map to a default AI image when the model has none', () {
      final entity = mapper.to(
        const PortraiAppConfigModel(minimumRequiredAppVersion: '1.2.3'),
      );

      expect(entity.aiImage, const AiImageAppConfig());
    });

    test('should map the AI assistant and rate limit when they are set', () {
      final entity = mapper.to(
        const PortraiAppConfigModel(
          minimumRequiredAppVersion: '1.2.3',
          aiAssistantModel: 'gemini-test',
          aiRateLimit: AiRateLimitAppConfigModel(
            maxRequestsPerMinute: 5,
            maxRequestsPerDay: 50,
          ),
        ),
      );

      expect(entity.aiAssistantModel, 'gemini-test');
      expect(
        entity.aiRateLimit,
        const AiRateLimitAppConfig(
          maxRequestsPerMinute: 5,
          maxRequestsPerDay: 50,
        ),
      );
    });

    test('should map to default AI settings when the model has none', () {
      final entity = mapper.to(
        const PortraiAppConfigModel(minimumRequiredAppVersion: '1.2.3'),
      );

      expect(entity.aiAssistantModel, isNull);
      expect(entity.aiRateLimit, const AiRateLimitAppConfig());
    });

    test('should round trip an entity through the model', () {
      const entity = PortraiAppConfigEntity(
        minimumRequiredAppVersion: '4.5.6',
        aiImage: AiImageAppConfig(model: 'model', style: 'manga'),
        aiAssistantModel: 'gemini-test',
        aiRateLimit: AiRateLimitAppConfig(
          maxRequestsPerMinute: 3,
          maxRequestsPerDay: 30,
        ),
        termsUrl: 'https://legal.example.com/terms',
        privacyPolicyUrl: 'https://legal.example.com/privacy',
      );

      expect(mapper.to(mapper.from(entity)), entity);
    });
  });
}
