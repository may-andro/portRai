import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/get_remote_assistant_preference_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure_mapper.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/reset_remote_assistant_session_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/update_remote_assistant_preference_use_case.dart';

import '../../../../../mock/feature/remote_assistant/domain/repository/mock_remote_assistant_repository.dart';

void main() {
  const preference = RemoteAssistantPreferenceEntity(
    enabled: true,
    consentAccepted: true,
  );

  setUp(() {
    registerFallbackValue(preference);
    registerFallbackValue(FakeAssistantMessageList());
    registerFallbackValue((String _) {});
  });

  final cases = <(Object, Matcher)>[
    (
      const AiQuotaExceededException('secret server body', StackTrace.empty),
      isA<RemoteAssistantQuotaFailure>(),
    ),
    (
      const AiNetworkException('secret server body', StackTrace.empty),
      isA<RemoteAssistantNetworkFailure>(),
    ),
    (
      const AiTimeoutException('secret server body', StackTrace.empty),
      isA<RemoteAssistantTimeoutFailure>(),
    ),
    (
      const AiServerException('secret server body', StackTrace.empty),
      isA<RemoteAssistantNetworkFailure>(),
    ),
    (
      const AiConfigurationException('secret server body', StackTrace.empty),
      isA<RemoteAssistantConfigurationFailure>(),
    ),
    (
      const AiUnsupportedLocationException(
        'secret server body',
        StackTrace.empty,
      ),
      isA<RemoteAssistantConfigurationFailure>(),
    ),
    (
      const AiBlockedResponseException(
        'secret generated text',
        StackTrace.empty,
      ),
      isA<RemoteAssistantBlockedFailure>(),
    ),
    (
      const AiInvalidInputException('secret prompt', StackTrace.empty),
      isA<RemoteAssistantInvalidInputFailure>(),
    ),
    (
      const AiIncompleteResponseException(
        'secret generated text',
        StackTrace.empty,
      ),
      isA<RemoteAssistantIncompleteFailure>(),
    ),
    (
      const AiEmptyResponseException('secret generated text', StackTrace.empty),
      isA<RemoteAssistantIncompleteFailure>(),
    ),
    (
      const AiSdkException('secret server body', StackTrace.empty),
      isA<RemoteAssistantUnknownFailure>(),
    ),
    (
      const RemoteAssistantPreferenceException(),
      isA<RemoteAssistantPreferenceFailure>(),
    ),
    (
      const RemoteAssistantClosedException(),
      isA<RemoteAssistantUnavailableFailure>(),
    ),
    (
      const RemoteAssistantConcurrentRequestException(),
      isA<RemoteAssistantUnavailableFailure>(),
    ),
    (
      const RemoteAssistantFlagException(),
      isA<RemoteAssistantConfigurationFailure>(),
    ),
    (
      const RemoteAssistantUnavailableException(),
      isA<RemoteAssistantUnavailableFailure>(),
    ),
    (
      const RemoteAssistantConsentRequiredException(),
      isA<RemoteAssistantConsentRequiredFailure>(),
    ),
    (
      const RemoteAssistantInvalidInputException(),
      isA<RemoteAssistantInvalidInputFailure>(),
    ),
    (
      const RemoteAssistantTimeoutException(),
      isA<RemoteAssistantTimeoutFailure>(),
    ),
    (
      const RemoteAssistantCancelledException(),
      isA<RemoteAssistantUnavailableFailure>(),
    ),
    (
      const RemoteAssistantCallbackException(),
      isA<RemoteAssistantUnknownFailure>(),
    ),
    (
      const RemoteAssistantIncompleteException(),
      isA<RemoteAssistantIncompleteFailure>(),
    ),
    (
      const RemoteAssistantResponseLimitException(),
      isA<RemoteAssistantIncompleteFailure>(),
    ),
  ];

  test(
    'should treat unexpected failure objects as unknown when mapping errors',
    () {
      const error = RemoteAssistantQuotaFailure(cause: 'secret server body');
      final result = mapRemoteAssistantFailure(error);
      expect(result, isA<RemoteAssistantUnknownFailure>());
      expect(result.cause, isNull);
      expect(result, isNot(same(error)));
    },
  );

  for (final operation in ['ask', 'get', 'update', 'reset']) {
    for (final (error, expected) in cases) {
      test(
        'should map ${error.runtimeType} without sensitive causes when $operation fails',
        () async {
          final repository = MockRemoteAssistantRepository()
            ..stubAnswerError(error)
            ..stubGetPreferenceError(error)
            ..stubUpdatePreferenceError(error)
            ..stubResetSessionError(error);
          final RemoteAssistantFailure failure;
          switch (operation) {
            case 'ask':
              final result =
                  await AskRemotePortfolioQuestionUseCase(repository)(
                    AskRemotePortfolioQuestionParams(
                      question: 'secret prompt',
                      portfolioContext: 'secret context',
                      history: const [],
                      onDelta: (_) {},
                    ),
                  );
              expect(result.isLeft, isTrue);
              failure = result.left;
            case 'get':
              final result = await GetRemoteAssistantPreferenceUseCase(
                repository,
              )();
              expect(result.isLeft, isTrue);
              failure = result.left;
            case 'update':
              final result = await UpdateRemoteAssistantPreferenceUseCase(
                repository,
              )(preference);
              expect(result.isLeft, isTrue);
              failure = result.left;
            case 'reset':
              final result = await ResetRemoteAssistantSessionUseCase(
                repository,
              )();
              expect(result.isLeft, isTrue);
              failure = result.left;
            default:
              throw StateError('Unsupported test operation');
          }
          expect(failure, expected);
          expect(failure.cause, isNull);
          expect(failure.toString(), isNot(contains('secret')));
        },
      );
    }
  }

  test(
    'should use operation-specific defaults when exceptions are unrecognized',
    () async {
      final error = StateError('secret server body');
      final repository = MockRemoteAssistantRepository()
        ..stubAnswerError(error)
        ..stubGetPreferenceError(error)
        ..stubUpdatePreferenceError(error)
        ..stubResetSessionError(error);
      final ask = await AskRemotePortfolioQuestionUseCase(repository)(
        AskRemotePortfolioQuestionParams(
          question: 'Question',
          portfolioContext: 'Context',
          history: const [],
          onDelta: (_) {},
        ),
      );
      final get = await GetRemoteAssistantPreferenceUseCase(repository)();
      final update = await UpdateRemoteAssistantPreferenceUseCase(repository)(
        preference,
      );
      final reset = await ResetRemoteAssistantSessionUseCase(repository)();
      expect(ask.left, isA<RemoteAssistantUnknownFailure>());
      expect(get.left, isA<RemoteAssistantPreferenceFailure>());
      expect(update.left, isA<RemoteAssistantPreferenceFailure>());
      expect(reset.left, isA<RemoteAssistantUnknownFailure>());
      for (final failure in [ask.left, get.left, update.left, reset.left]) {
        expect(failure.cause, isNull);
        expect(failure.toString(), isNot(contains('secret')));
      }
    },
  );
}
