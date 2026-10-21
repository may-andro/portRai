import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_event.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_state.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@register
class JobOpeningBloc extends Bloc<JobOpeningEvent, JobOpeningState> {
  JobOpeningBloc(
    this._getJobOpeningUseCase,
    this._openExternalUrlUseCase,
    this._getProfileUseCase,
    this._trackingDelegate,
  ) : super(const JobOpeningState()) {
    on<JobOpeningStartedEvent>(_mapJobOpeningStartedEventToState);
    on<JobOpeningRetryClickEvent>(_mapJobOpeningRetryClickEventToState);
    on<ApplyClickEvent>(_mapApplyClickEventToState);
  }

  final GetJobOpeningUseCase _getJobOpeningUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final GetProfileUseCase _getProfileUseCase;
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
  }
}
