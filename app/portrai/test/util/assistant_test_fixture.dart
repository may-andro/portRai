import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/ask_local_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/utility/local_assistant_feature_access_use_case.dart';
import 'package:use_case/use_case.dart';

import '../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';
import '../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_ask_local_portfolio_question_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_cancel_local_assistant_preparation_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_delete_local_assistant_model_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_get_local_assistant_enabled_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_model_downloaded_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_prepare_local_assistant_model_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_reset_local_assistant_session_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_update_local_assistant_enabled_use_case.dart';
import '../mock/feature/local_assistant/presentation/screen/local_assistant/tracking/mock_local_assistant_tracking_delegate.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_ask_remote_portfolio_question_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_get_remote_assistant_preference_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_reset_remote_assistant_session_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_update_remote_assistant_preference_use_case.dart';
import '../mock/feature/remote_assistant/presentation/screen/remote_assistant/tracking/mock_remote_assistant_tracking_delegate.dart';

/// Creates real independent blocs with deterministic, non-network use cases.
class AssistantTestFixture {
  AssistantTestFixture({
    bool localRollout = true,
    bool remoteRollout = true,
    bool localSupported = true,
    bool remoteSupported = true,
    bool localEnabled = false,
    bool remoteEnabled = false,
  }) {
    setRollout(local: localRollout, remote: remoteRollout);
    when(() => context()).thenAnswer((_) => const Right('Fixture portfolio'));
    final prepare = MockPrepareLocalAssistantModelUseCase()
      ..stubCall(const Right(null));
    final enabled = MockGetLocalAssistantEnabledUseCase()
      ..stubCall(Right(localEnabled));
    final downloaded = MockIsLocalAssistantModelDownloadedUseCase()
      ..stubCall(const Right(true));
    updateLocal.stubCall(const Right(null));
    final cancel = MockCancelLocalAssistantPreparationUseCase()
      ..stubCall(const Right(null));
    final delete = MockDeleteLocalAssistantModelUseCase()
      ..stubCall(const Right(null));
    resetLocal.stubCall(const Right(null));
    askLocal.stubCall(
      params: const AskLocalPortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Fixture portfolio',
      ),
      result: const Right(AssistantTextResponseEntity(text: 'Local answer')),
    );
    local = LocalAssistantBloc(
      context,
      prepare,
      enabled,
      updateLocal,
      cancel,
      delete,
      downloaded,
      askLocal,
      MockLocalAssistantTrackingDelegate(),
      LocalAssistantFeatureAccessUseCase(flagRepository),
      availability: LocalAssistantAvailability.supported(localSupported),
      resetSession: resetLocal,
    );
    preference = RemoteAssistantPreferenceEntity(
      enabled: remoteEnabled,
      consentAccepted: remoteEnabled,
    );
    when(() => getRemote()).thenAnswer((_) => Right(preference));
    when(() => updateRemote(any())).thenAnswer((invocation) {
      preference =
          invocation.positionalArguments.single
              as RemoteAssistantPreferenceEntity;
      return const Right(null);
    });
    when(() => resetRemote()).thenAnswer((_) => const Right(null));
    when(() => askRemote(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single
              as AskRemotePortfolioQuestionParams;
      params.onDelta('Cloud answer');
      return const Right(null);
    });
    remote = RemoteAssistantBloc(
      context,
      getRemote,
      updateRemote,
      resetRemote,
      askRemote,
      flag,
      remoteTracking,
      availability: RemoteAssistantAvailability.supported(remoteSupported),
    );
    addTearDown(() async {
      await local.close();
      await remote.close();
    });
  }

  static void registerFallbacks() {
    registerFallbackValue(
      const RemoteAssistantPreferenceEntity(
        enabled: false,
        consentAccepted: false,
      ),
    );
    registerFallbackValue(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Fixture portfolio',
        history: const [],
        onDelta: (_) {},
      ),
    );
    registerFallbackValue(
      const AskLocalPortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Fixture portfolio',
      ),
    );
    registerFallbackValue((int _) {});
  }

  final context = MockGetAssistantContextUseCase();
  final flag = MockIsFeatureEnabledUseCase();
  final flagRepository = MockAppFeatureFlagRepository();
  final askLocal = MockAskLocalPortfolioQuestionUseCase();
  final askRemote = MockAskRemotePortfolioQuestionUseCase();
  final resetLocal = MockResetLocalAssistantSessionUseCase();
  final resetRemote = MockResetRemoteAssistantSessionUseCase();
  final updateLocal = MockUpdateLocalAssistantEnabledUseCase();
  final getRemote = MockGetRemoteAssistantPreferenceUseCase();
  final updateRemote = MockUpdateRemoteAssistantPreferenceUseCase();
  final remoteTracking = MockRemoteAssistantTrackingDelegate();
  late RemoteAssistantPreferenceEntity preference;
  late final LocalAssistantBloc local;
  late final RemoteAssistantBloc remote;

  void setRollout({required bool local, required bool remote}) {
    flagRepository
      ..stubIsFeatureEnabled(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        isEnabled: local,
      )
      ..stubIsFeatureEnabled(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        isEnabled: remote,
      );
    flag.stubCall(
      definition: RemoteAssistantFeatureFlags.remoteAssistant,
      result: Right(remote),
    );
  }

  void start() {
    local.add(const LocalAssistantStartedEvent());
    remote.add(const RemoteAssistantStartedEvent());
  }
}
