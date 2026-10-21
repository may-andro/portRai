import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/controller/job_opening_insights_genui_controller_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_event.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_state.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

@register
class JobOpeningBloc extends Bloc<JobOpeningEvent, JobOpeningState> {
  JobOpeningBloc(
    this._getJobOpeningUseCase,
    this._openExternalUrlUseCase,
    this._getProfileUseCase,
    this._isJobOpeningInsightsAvailableUseCase,
    this._getAssistantContextUseCase,
    this._askRemotePortfolioQuestionUseCase,
    this._resetRemoteAssistantSessionUseCase,
    this._trackingDelegate,
  ) : super(const JobOpeningState()) {
    on<JobOpeningStartedEvent>(_mapJobOpeningStartedEventToState);
    on<JobOpeningRetryClickEvent>(_mapJobOpeningRetryClickEventToState);
    on<ApplyClickEvent>(_mapApplyClickEventToState);
    on<GenerateInsightsClickEvent>(_mapGenerateInsightsClickEventToState);
  }

  final GetJobOpeningUseCase _getJobOpeningUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final IsJobOpeningInsightsAvailableUseCase
  _isJobOpeningInsightsAvailableUseCase;
  final GetAssistantContextUseCase _getAssistantContextUseCase;
  final AskRemotePortfolioQuestionUseCase _askRemotePortfolioQuestionUseCase;
  final ResetRemoteAssistantSessionUseCase _resetRemoteAssistantSessionUseCase;
  final JobOpeningTrackingDelegate _trackingDelegate;

  Future<void> _mapJobOpeningStartedEventToState(
    JobOpeningStartedEvent event,
    Emitter<JobOpeningState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    emit(state.copyWith(id: event.id));
    await _loadJobOpening(emit);
    // Only the footer needs it, so it loads after the page content.
    final profileEither = await _getProfileUseCase();
    if (profileEither.isRight) {
      emit(state.copyWith(profile: profileEither.right));
    }
  }

  Future<void> _mapJobOpeningRetryClickEventToState(
    JobOpeningRetryClickEvent event,
    Emitter<JobOpeningState> emit,
  ) => _loadJobOpening(emit);

  Future<void> _mapApplyClickEventToState(
    ApplyClickEvent event,
    Emitter<JobOpeningState> emit,
  ) async {
    final jobOpening = state.jobOpening;
    if (jobOpening == null) return;

    _trackingDelegate.trackApplyClick(jobOpening.sourceName);
    emit(state.copyWith(clearApplyFailure: true));
    final openExternalUrlEither = await _openExternalUrlUseCase(
      OpenExternalUrlParam(jobOpening.url),
    );
    if (openExternalUrlEither.isLeft) {
      emit(state.copyWith(applyFailure: openExternalUrlEither.left));
    }
  }

  Future<void> _mapGenerateInsightsClickEventToState(
    GenerateInsightsClickEvent event,
    Emitter<JobOpeningState> emit,
  ) async {
    final jobOpening = state.jobOpening;
    if (jobOpening == null ||
        state.insightsStatus == JobOpeningInsightsStatus.unavailable ||
        state.insightsStatus == JobOpeningInsightsStatus.generating) {
      return;
    }

    _trackingDelegate.trackGenerateInsightsClick(jobOpening.sourceName);
    state.insightsController?.dispose();
    emit(
      state.copyWith(
        insightsStatus: JobOpeningInsightsStatus.generating,
        clearInsightsController: true,
        insightsSurfaceIds: const [],
        clearInsightsFailure: true,
      ),
    );
    final assistantContextEither = await _getAssistantContextUseCase();
    if (assistantContextEither.isLeft) {
      emit(
        state.copyWith(
          insightsStatus: JobOpeningInsightsStatus.failed,
          insightsFailure: assistantContextEither.left,
        ),
      );
      return;
    }

    final controller = AssistantGenuiController();
    emit(state.copyWith(insightsController: controller));
    final insightsEither = await controller.sendJobOpeningInsightsRequest(
      askRemotePortfolioQuestionUseCase: _askRemotePortfolioQuestionUseCase,
      jobOpening: jobOpening,
      portfolioContext: assistantContextEither.right,
      onSurfaceUpdate: (_) {
        if (emit.isDone || !identical(state.insightsController, controller)) {
          return;
        }
        emit(
          state.copyWith(
            insightsSurfaceIds: List.unmodifiable(controller.activeSurfaceIds),
          ),
        );
      },
    );
    if (emit.isDone || !identical(state.insightsController, controller)) {
      return;
    }
    if (insightsEither.isLeft) {
      controller.dispose();
      emit(
        state.copyWith(
          insightsStatus: JobOpeningInsightsStatus.failed,
          clearInsightsController: true,
          insightsSurfaceIds: const [],
          insightsFailure: insightsEither.left,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        insightsStatus: JobOpeningInsightsStatus.ready,
        insightsSurfaceIds: List.unmodifiable(controller.activeSurfaceIds),
      ),
    );
  }

  Future<void> _loadJobOpening(Emitter<JobOpeningState> emit) async {
    emit(
      state.copyWith(status: JobOpeningStatus.loading, clearLoadFailure: true),
    );
    final jobOpeningEither = await _getJobOpeningUseCase(state.id);
    if (jobOpeningEither.isLeft) {
      emit(
        state.copyWith(
          status: JobOpeningStatus.failed,
          loadFailure: jobOpeningEither.left,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEither.right,
      ),
    );
    if (state.insightsStatus != JobOpeningInsightsStatus.unavailable) return;
    final isInsightsAvailableEither =
        await _isJobOpeningInsightsAvailableUseCase();
    if (isInsightsAvailableEither.isRight && isInsightsAvailableEither.right) {
      emit(state.copyWith(insightsStatus: JobOpeningInsightsStatus.idle));
    }
  }

  @override
  Future<void> close() async {
    final isGeneratingInsights =
        state.insightsStatus == JobOpeningInsightsStatus.generating;
    final controller = state.insightsController;
    await super.close();
    controller?.dispose();
    // Cancels the request still generating insights for this page.
    if (isGeneratingInsights) await _resetRemoteAssistantSessionUseCase();
  }
}
