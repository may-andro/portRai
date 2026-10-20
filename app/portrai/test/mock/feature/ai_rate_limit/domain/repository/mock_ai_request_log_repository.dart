import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/repository/_repository.dart';

class MockAiRequestLogRepository extends Mock
    implements AiRequestLogRepository {}

extension MockAiRequestLogRepositoryStub on MockAiRequestLogRepository {
  /// Stubs `getAiRequestLog()` to return [aiRequestLog].
  void stubGetAiRequestLog(AiRequestLogEntity aiRequestLog) {
    when(getAiRequestLog).thenAnswer((_) async => aiRequestLog);
  }

  /// Stubs `getAiRequestLog()` to throw [error].
  void stubGetAiRequestLogThrows(Object error) {
    when(getAiRequestLog).thenThrow(error);
  }

  /// Stubs `cacheAiRequestLog(aiRequestLog)` to complete successfully.
  void stubCacheAiRequestLog() {
    when(() => cacheAiRequestLog(any())).thenAnswer((_) async {});
  }
}
