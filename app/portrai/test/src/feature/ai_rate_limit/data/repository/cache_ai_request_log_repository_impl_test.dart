import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/_data.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/_domain.dart';

import '../../../../../mock/feature/ai_rate_limit/data/cache/fake_ai_request_log_model.dart';
import '../../../../../mock/feature/ai_rate_limit/data/cache/mock_ai_request_log_cache.dart';

void main() {
  group('CacheAiRequestLogRepositoryImpl', () {
    late MockAiRequestLogCache aiRequestLogCache;
    late CacheAiRequestLogRepositoryImpl repository;
    final requestTime = DateTime(2026, 10, 20, 12);

    setUpAll(() {
      registerFallbackValue(FakeAiRequestLogModel());
    });

    setUp(() {
      aiRequestLogCache = MockAiRequestLogCache();
      repository = CacheAiRequestLogRepositoryImpl(
        aiRequestLogCache,
        const AiRequestLogMapper(),
      );
    });

    test('should return an empty log when nothing is cached', () async {
      aiRequestLogCache.stubGet(null);

      expect(await repository.getAiRequestLog(), const AiRequestLogEntity());
    });

    test('should return the cached log when one is cached', () async {
      aiRequestLogCache.stubGet(
        AiRequestLogModel(
          requestTimesInMilliseconds: [requestTime.millisecondsSinceEpoch],
        ),
      );

      expect(
        await repository.getAiRequestLog(),
        AiRequestLogEntity(requestTimes: [requestTime]),
      );
    });

    test('should store the log as a model when it is cached', () async {
      aiRequestLogCache.stubPut();

      await repository.cacheAiRequestLog(
        AiRequestLogEntity(requestTimes: [requestTime]),
      );

      final storedAiRequestLog =
          verify(() => aiRequestLogCache.put(captureAny())).captured.single
              as AiRequestLogModel;
      expect(storedAiRequestLog.requestTimesInMilliseconds, [
        requestTime.millisecondsSinceEpoch,
      ]);
    });

    test('should throw a cache exception when reading the cache fails', () {
      aiRequestLogCache.stubGetThrows(StateError('read failed'));

      expect(
        repository.getAiRequestLog,
        throwsA(isA<AiRequestLogCacheException>()),
      );
    });

    test('should throw a cache exception when writing the cache fails', () {
      aiRequestLogCache.stubPutThrows(StateError('write failed'));

      expect(
        () => repository.cacheAiRequestLog(const AiRequestLogEntity()),
        throwsA(isA<AiRequestLogCacheException>()),
      );
    });
  });
}
