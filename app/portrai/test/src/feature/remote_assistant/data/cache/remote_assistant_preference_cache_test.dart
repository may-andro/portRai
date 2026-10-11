import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/data/cache/remote_assistant_preference_cache.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';

void main() {
  final cache = RemoteAssistantPreferenceCache();

  test('should use a distinct cache key when storing remote preferences', () {
    expect(
      RemoteAssistantPreferenceCache.cacheKey,
      'remote_assistant_preference_cache',
    );
    expect(
      RemoteAssistantPreferenceCache.cacheKey,
      isNot('assistant_enabled_cache'),
    );
  });

  test(
    'should persist consent version separately from enablement when serializing',
    () {
      expect(
        cache.serializeValue(
          const RemoteAssistantPreferenceEntity(
            enabled: true,
            consentAccepted: true,
          ),
        ),
        {'consentVersion': 1, 'consentAccepted': true, 'enabled': true},
      );
    },
  );

  test(
    'should disable remote access when consent is withdrawn during serialization',
    () {
      expect(
        cache.serializeValue(
          const RemoteAssistantPreferenceEntity(
            enabled: true,
            consentAccepted: false,
          ),
        ),
        {'consentVersion': 1, 'consentAccepted': false, 'enabled': false},
      );
    },
  );

  test('should reject consent from a previous version when deserializing', () {
    final result = cache.deserializeValue({
      'consentVersion': 0,
      'consentAccepted': true,
      'enabled': true,
    });

    expect(result.consentAccepted, isFalse);
    expect(result.enabled, isFalse);
  });

  test(
    'should reject legacy data with no versioned consent when deserializing',
    () {
      final result = cache.deserializeValue({
        'enabled': true,
        'consentAccepted': true,
      });

      expect(result.consentAccepted, isFalse);
      expect(result.enabled, isFalse);
    },
  );

  test(
    'should preserve independently accepted consent and enablement when deserializing',
    () {
      final result = cache.deserializeValue({
        'consentVersion': 1,
        'consentAccepted': true,
        'enabled': false,
      });

      expect(result.consentAccepted, isTrue);
      expect(result.enabled, isFalse);
    },
  );
}
