import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/data/cache/local_assistant_enabled_cache.dart';

class MockLocalAssistantEnabledCache extends Mock
    implements LocalAssistantEnabledCache {}

extension MockLocalAssistantEnabledCacheStub on MockLocalAssistantEnabledCache {
  void stubGet(bool? enabled) {
    when(() => get()).thenAnswer((_) async => enabled);
  }

  void stubPut(bool saved) {
    when(() => put(any())).thenAnswer((_) async => saved);
  }
}
