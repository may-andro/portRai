import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/cache/ai_request_log_cache.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/model/_model.dart';

class MockAiRequestLogCache extends Mock implements AiRequestLogCache {}

extension MockAiRequestLogCacheStub on MockAiRequestLogCache {
  /// Stubs `get()` to return [aiRequestLog].
  void stubGet(AiRequestLogModel? aiRequestLog) {
    when(get).thenAnswer((_) async => aiRequestLog);
  }

  /// Stubs `get()` to throw [error].
  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  /// Stubs `put(aiRequestLog)` to complete successfully.
  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }

  /// Stubs `put(aiRequestLog)` to throw [error].
  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }
}
