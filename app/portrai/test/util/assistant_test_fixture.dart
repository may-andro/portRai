import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/ask_local_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_event.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/remote_assistant/domain/feature_flag/remote_assistant_feature_flags.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_event.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';
import '../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_ask_local_portfolio_question_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_cancel_local_assistant_preparation_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_delete_local_assistant_model_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_get_local_assistant_enabled_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_model_downloaded_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_prepare_local_assistant_model_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_reset_local_assistant_session_use_case.dart';
import '../mock/feature/local_assistant/domain/use_case/mock_update_local_assistant_enabled_use_case.dart';
import '../mock/feature/local_assistant/presentation/screen/local_assistant/tracking/mock_local_assistant_tracking_delegate.dart';
import '../mock/feature/permission/domain/use_case/mock_request_permission_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_ask_remote_portfolio_question_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';
import '../mock/feature/remote_assistant/domain/use_case/mock_reset_remote_assistant_session_use_case.dart';
import '../mock/feature/remote_assistant/presentation/screen/remote_assistant/tracking/mock_remote_assistant_tracking_delegate.dart';
import '../mock/feature/user/domain/use_case/mock_get_guest_user_use_case.dart';

/// Creates real independent blocs with deterministic, non-network use cases.
class AssistantTestFixture {
  AssistantTestFixture({
    bool localRollout = true,
    bool remoteRollout = true,
    bool remoteGenerativeUi = false,
    bool localSupported = true,
    bool remoteSupported = true,
    bool localEnabled = false,
  }) {
    isLocalAssistantSupportedUseCase = MockIsLocalAssistantSupportedUseCase()
      ..stubCall(localSupported);
    setRollout(
      local: localRollout,
      remote: remoteRollout,
      remoteGenerativeUi: remoteGenerativeUi,
    );
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
      IsFeatureEnabledUseCase(flagRepository),
      isLocalAssistantSupportedUseCase: isLocalAssistantSupportedUseCase,
      resetLocalAssistantSessionUseCase: resetLocal,
      requestPermissionUseCase: MockRequestPermissionUseCase()
        ..stubCall(
          AppPermission.notifications,
          const Right(AppPermissionStatus.granted),
        ),
    );
    when(() => resetRemote()).thenAnswer((_) => const Right(null));
    remoteSupport.stubCall(Right(remoteSupported));
    when(() => askRemote(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single
              as AskRemotePortfolioQuestionParams;
      params.onDelta('Cloud answer');
      return const Right(null);
    });
    remote = RemoteAssistantBloc(
      context,
      resetRemote,
      askRemote,
      flag,
      remoteSupport,
      MockOpenExternalUrlUseCase(),
      remoteTracking,
      MockGetGuestUserUseCase()..stubCall(null),
    );
    addTearDown(() async {
      await local.close();
      await remote.close();
    });
  }

  static void registerFallbacks() {
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
  final remoteTracking = MockRemoteAssistantTrackingDelegate();
  final remoteSupport = MockIsRemoteAssistantSupportedUseCase();
  late final LocalAssistantBloc local;
  late final RemoteAssistantBloc remote;
  late final MockIsLocalAssistantSupportedUseCase
  isLocalAssistantSupportedUseCase;

  /// Installs module-owned instances; public cards/routes own their providers.
  void install() {
    appServiceLocator.registerSingleton<LocalAssistantBloc>(() => local);
    appServiceLocator.registerSingleton<RemoteAssistantBloc>(() => remote);
  }

  void setRollout({
    required bool local,
    required bool remote,
    bool remoteGenerativeUi = false,
  }) {
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
    flag.stubCall(
      definition: RemoteAssistantFeatureFlags.generativeUi,
      result: Right(remoteGenerativeUi),
    );
    flag.stubCall(
      definition: LocalAssistantFeatureFlags.aiAssistant,
      result: Right(local),
    );
  }

  void start() {
    local.add(const LocalAssistantStartedEvent());
    remote.add(const RemoteAssistantStartedEvent());
  }
}
