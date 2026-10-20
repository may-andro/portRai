import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/_domain.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

import '../../../../../mock/feature/ai_rate_limit/domain/entity/fake_ai_request_log_entity.dart';
import '../../../../../mock/feature/ai_rate_limit/domain/repository/mock_ai_request_log_repository.dart';

void main() {
  group('ConsumeAiRequestQuotaUseCase', () {
    late MockAiRequestLogRepository aiRequestLogRepository;

    setUpAll(() {
      registerFallbackValue(FakeAiRequestLogEntity());
    });

    setUp(() {
      aiRequestLogRepository = MockAiRequestLogRepository()
        ..stubCacheAiRequestLog();
    });

    ConsumeAiRequestQuotaUseCase buildUseCase({
      AiRateLimitAppConfig aiRateLimit = const AiRateLimitAppConfig(),
    }) => ConsumeAiRequestQuotaUseCase(
      aiRequestLogRepository,
      PortraiAppConfigEntity(
        minimumRequiredAppVersion: '1.0.0',
        aiRateLimit: aiRateLimit,
      ),
    );

    List<DateTime> requestTimesAgo(int requestCount, Duration age) => [
      for (var requestIndex = 0; requestIndex < requestCount; requestIndex++)
        DateTime.now().subtract(age),
    ];

    test('should record the request when the budget is not used up', () async {
      aiRequestLogRepository.stubGetAiRequestLog(const AiRequestLogEntity());

      final consumeAiRequestQuotaEither = await buildUseCase()();

      expect(consumeAiRequestQuotaEither.isRight, isTrue);
      final storedAiRequestLog =
          verify(
                () => aiRequestLogRepository.cacheAiRequestLog(captureAny()),
              ).captured.single
              as AiRequestLogEntity;
      expect(storedAiRequestLog.requestTimes, hasLength(1));
    });

    test(
      'should return quota exceeded when the per-minute limit is reached',
      () async {
        aiRequestLogRepository.stubGetAiRequestLog(
          AiRequestLogEntity(
            requestTimes: requestTimesAgo(2, const Duration(seconds: 10)),
          ),
        );

        final consumeAiRequestQuotaEither = await buildUseCase(
          aiRateLimit: const AiRateLimitAppConfig(maxRequestsPerMinute: 2),
        )();

        expect(
          consumeAiRequestQuotaEither.left,
          isA<AiRequestQuotaExceededFailure>(),
        );
        verifyNever(() => aiRequestLogRepository.cacheAiRequestLog(any()));
      },
    );

    test(
      'should return quota exceeded when the per-day limit is reached',
      () async {
        aiRequestLogRepository.stubGetAiRequestLog(
          AiRequestLogEntity(
            requestTimes: requestTimesAgo(3, const Duration(hours: 2)),
          ),
        );

        final consumeAiRequestQuotaEither = await buildUseCase(
          aiRateLimit: const AiRateLimitAppConfig(maxRequestsPerDay: 3),
        )();

        expect(
          consumeAiRequestQuotaEither.left,
          isA<AiRequestQuotaExceededFailure>(),
        );
      },
    );

    test('should drop expired requests when the log is stored again', () async {
      aiRequestLogRepository.stubGetAiRequestLog(
        AiRequestLogEntity(
          requestTimes: requestTimesAgo(5, const Duration(days: 2)),
        ),
      );

      final consumeAiRequestQuotaEither = await buildUseCase(
        aiRateLimit: const AiRateLimitAppConfig(maxRequestsPerDay: 1),
      )();

      expect(consumeAiRequestQuotaEither.isRight, isTrue);
      final storedAiRequestLog =
          verify(
                () => aiRequestLogRepository.cacheAiRequestLog(captureAny()),
              ).captured.single
              as AiRequestLogEntity;
      expect(storedAiRequestLog.requestTimes, hasLength(1));
    });

    test(
      'should still count requests when they are ahead of the device clock',
      () async {
        aiRequestLogRepository.stubGetAiRequestLog(
          AiRequestLogEntity(
            requestTimes: [DateTime.now().add(const Duration(hours: 1))],
          ),
        );

        final consumeAiRequestQuotaEither = await buildUseCase(
          aiRateLimit: const AiRateLimitAppConfig(maxRequestsPerDay: 1),
        )();

        expect(
          consumeAiRequestQuotaEither.left,
          isA<AiRequestQuotaExceededFailure>(),
        );
      },
    );

    test('should block every request when a limit is zero', () async {
      aiRequestLogRepository.stubGetAiRequestLog(const AiRequestLogEntity());

      final consumeAiRequestQuotaEither = await buildUseCase(
        aiRateLimit: const AiRateLimitAppConfig(maxRequestsPerDay: 0),
      )();

      expect(
        consumeAiRequestQuotaEither.left,
        isA<AiRequestQuotaExceededFailure>(),
      );
    });

    test(
      'should use the default limits when the values are negative',
      () async {
        aiRequestLogRepository.stubGetAiRequestLog(
          AiRequestLogEntity(
            requestTimes: requestTimesAgo(
              ConsumeAiRequestQuotaUseCase.defaultMaxRequestsPerMinute - 1,
              const Duration(seconds: 10),
            ),
          ),
        );

        final consumeAiRequestQuotaEither = await buildUseCase(
          aiRateLimit: const AiRateLimitAppConfig(
            maxRequestsPerMinute: -1,
            maxRequestsPerDay: -1,
          ),
        )();

        expect(consumeAiRequestQuotaEither.isRight, isTrue);
      },
    );

    test('should return a cache failure when the log cannot be read', () async {
      aiRequestLogRepository.stubGetAiRequestLogThrows(
        const AiRequestLogCacheException(),
      );

      final consumeAiRequestQuotaEither = await buildUseCase()();

      expect(
        consumeAiRequestQuotaEither.left,
        isA<AiRequestQuotaCacheFailure>(),
      );
    });

    test(
      'should return an unknown failure when an unexpected error is thrown',
      () async {
        aiRequestLogRepository.stubGetAiRequestLogThrows(StateError('broken'));

        final consumeAiRequestQuotaEither = await buildUseCase()();

        expect(
          consumeAiRequestQuotaEither.left,
          isA<AiRequestQuotaUnknownFailure>(),
        );
      },
    );
  });
}
