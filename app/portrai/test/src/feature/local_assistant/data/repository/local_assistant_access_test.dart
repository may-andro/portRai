import 'dart:async';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/flutter_edge_ai_local_assistant_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant_availability.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../mock/feature/local_assistant/data/cache/mock_local_assistant_enabled_cache.dart';
import '../../../../../mock/feature/local_assistant/data/repository/mock_inference_chat.dart';
import '../../../../../mock/feature/local_assistant/data/repository/mock_inference_model.dart';

void main() {
  setUpAll(
    () => registerFallbackValue(const Message(text: 'Ready', isUser: true)),
  );

  for (final reason in [
    'flag off',
    'unsupported platform',
    'disabled',
    'flag failure',
  ]) {
    test(
      'should reject inference before loading when $reason blocks local access',
      () async {
        final cache = MockLocalAssistantEnabledCache()
          ..stubGet(reason != 'disabled');
        final flag = MockIsFeatureEnabledUseCase()
          ..stubCall(
            definition: LocalAssistantFeatureFlags.aiAssistant,
            result: reason == 'flag failure'
                ? const Left(FeatureFlagUnknownFailure())
                : Right(reason != 'flag off'),
          );
        var loads = 0;
        final repository =
            FlutterEdgeAiLocalAssistantRepository.withModelLoader(
              (_) {
                loads++;
                throw StateError('Must not load');
              },
              enabledCache: cache,
              isFeatureEnabled: flag,
              availability: LocalAssistantAvailability.supported(
                reason != 'unsupported platform',
              ),
            );
        addTearDown(repository.dispose);
        await expectLater(
          repository.answer(question: 'Question', portfolioContext: 'Fixture'),
          throwsA(isA<LocalAssistantException>()),
        );
        expect(loads, 0);
        if (reason != 'disabled') {
          await expectLater(
            repository.setEnabled(enabled: true),
            throwsA(isA<LocalAssistantException>()),
          );
          verifyNever(() => cache.put(true));
        }
      },
    );
  }

  test(
    'should stay fail-closed when saving the local disable preference fails',
    () async {
      final cache = MockLocalAssistantEnabledCache()
        ..stubGet(true)
        ..stubPut(false);
      final flag = MockIsFeatureEnabledUseCase()
        ..stubCall(
          definition: LocalAssistantFeatureFlags.aiAssistant,
          result: const Right(true),
        );
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => throw StateError('Must not load'),
        enabledCache: cache,
        isFeatureEnabled: flag,
      );
      addTearDown(repository.dispose);
      await expectLater(
        repository.setEnabled(enabled: false),
        throwsA(isA<LocalAssistantPreferenceException>()),
      );
      await expectLater(
        repository.answer(question: 'Question', portfolioContext: 'Fixture'),
        throwsA(isA<LocalAssistantCancelledException>()),
      );
    },
  );

  test(
    'should persist revocation last when enabling and disabling overlap',
    () async {
      final cache = MockLocalAssistantEnabledCache()..stubGet(true);
      final flag = MockIsFeatureEnabledUseCase()
        ..stubCall(
          definition: LocalAssistantFeatureFlags.aiAssistant,
          result: const Right(true),
        );
      final enabledSave = Completer<bool>();
      final writes = <bool>[];
      when(() => cache.put(any())).thenAnswer((invocation) async {
        final enabled = invocation.positionalArguments.single as bool;
        writes.add(enabled);
        return !enabled || await enabledSave.future;
      });
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => throw StateError('Must not load'),
        enabledCache: cache,
        isFeatureEnabled: flag,
      );
      addTearDown(repository.dispose);
      final enable = repository.setEnabled(enabled: true);
      await pumpEventQueue();
      final disable = repository.setEnabled(enabled: false);
      enabledSave.complete(true);
      await Future.wait([enable, disable]);
      expect(writes, [true, false]);
      await expectLater(
        repository.answer(question: 'Question', portfolioContext: 'Fixture'),
        throwsA(isA<LocalAssistantCancelledException>()),
      );
    },
  );

  test(
    'should discard obsolete output and reject overlapping work when reset occurs during native preparation',
    () async {
      final model = MockInferenceModel();
      final chat = MockInferenceChat();
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenAnswer((_) async => chat);
      when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
      final response = Completer<TextResponse>();
      when(
        () => chat.generateChatResponse(),
      ).thenAnswer((_) => response.future);
      when(() => chat.close()).thenAnswer((_) async {});
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => model,
      );
      addTearDown(repository.dispose);
      final preparation = repository.answer(
        question: 'Question',
        portfolioContext: 'Fixture',
      );
      final assertion = expectLater(
        preparation,
        throwsA(isA<LocalAssistantCancelledException>()),
      );
      await pumpEventQueue();
      await repository.resetSession();
      await expectLater(
        repository.answer(
          question: 'Another question',
          portfolioContext: 'Fixture',
        ),
        throwsA(isA<LocalAssistantBusyException>()),
      );
      response.complete(const TextResponse('Ready'));
      await assertion;
      verify(() => model.close()).called(1);
    },
  );
}
