import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_event.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_state.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@register
class JobOpeningsBloc extends Bloc<JobOpeningsEvent, JobOpeningsState> {
  JobOpeningsBloc(
    this._getJobOpeningsUseCase,
    this._isJobSearchEnabledUseCase,
    this._setJobSearchEnabledUseCase,
    this._signOutUseCase,
    this._getProfileUseCase,
    this._trackingDelegate,
  ) : super(const JobOpeningsState()) {
    on<JobOpeningsStartedEvent>(_mapJobOpeningsStartedEventToState);
    on<JobOpeningsRetryClickEvent>(_mapJobOpeningsRetryClickEventToState);
    on<JobOpeningClickEvent>(_mapJobOpeningClickEventToState);
    on<JobSearchToggleClickEvent>(_mapJobSearchToggleClickEventToState);
    on<SignOutClickEvent>(_mapSignOutClickEventToState);
  }

  final GetJobOpeningsUseCase _getJobOpeningsUseCase;
  final IsJobSearchEnabledUseCase _isJobSearchEnabledUseCase;
  final SetJobSearchEnabledUseCase _setJobSearchEnabledUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final JobOpeningsTrackingDelegate _trackingDelegate;

  Future<void> _mapJobOpeningsStartedEventToState(
    JobOpeningsStartedEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await Future.wait([_loadJobOpenings(emit), _loadJobSearch(emit)]);
    // Only the footer needs it, so it loads after the page content.
    final profileEither = await _getProfileUseCase();
    if (profileEither.isRight) {
      emit(state.copyWith(profile: profileEither.right));
    }
  }

  Future<void> _mapJobOpeningsRetryClickEventToState(
    JobOpeningsRetryClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    await Future.wait([
      _loadJobOpenings(emit),
      if (state.isJobSearchEnabled == null) _loadJobSearch(emit),
    ]);
  }

  void _mapJobOpeningClickEventToState(
    JobOpeningClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) {
    _trackingDelegate.trackJobOpeningClick();
  }

  Future<void> _mapJobSearchToggleClickEventToState(
    JobSearchToggleClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    if (state.isUpdatingJobSearch) return;

    _trackingDelegate.trackJobSearchToggle(isEnabled: event.isEnabled);
    emit(state.copyWith(isUpdatingJobSearch: true, clearActionFailure: true));

    final setJobSearchEnabledEither = await _setJobSearchEnabledUseCase(
      event.isEnabled,
    );
    if (setJobSearchEnabledEither.isLeft) {
      emit(
        state.copyWith(
          isUpdatingJobSearch: false,
          actionFailure: setJobSearchEnabledEither.left,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isUpdatingJobSearch: false,
        isJobSearchEnabled: event.isEnabled,
      ),
    );
  }

  Future<void> _mapSignOutClickEventToState(
    SignOutClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    if (state.isSigningOut || state.isSignedOut) return;

    _trackingDelegate.trackSignOutClick();
    emit(state.copyWith(isSigningOut: true, clearActionFailure: true));

    final signOutEither = await _signOutUseCase();
    if (signOutEither.isLeft) {
      emit(
        state.copyWith(isSigningOut: false, actionFailure: signOutEither.left),
      );
      return;
    }
    emit(state.copyWith(isSigningOut: false, isSignedOut: true));
  }

  Future<void> _loadJobOpenings(Emitter<JobOpeningsState> emit) async {
    emit(
      state.copyWith(status: JobOpeningsStatus.loading, clearLoadFailure: true),
    );
    final jobOpeningsEither = await _getJobOpeningsUseCase();
    if (jobOpeningsEither.isLeft) {
      emit(
        state.copyWith(
          status: JobOpeningsStatus.failed,
          loadFailure: jobOpeningsEither.left,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: JobOpeningsStatus.loaded,
        jobOpenings: jobOpeningsEither.right,
      ),
    );
  }

  Future<void> _loadJobSearch(Emitter<JobOpeningsState> emit) async {
    final isJobSearchEnabledEither = await _isJobSearchEnabledUseCase();
    // A setting that cannot be read leaves the switch hidden; the list still
    // shows.
    if (isJobSearchEnabledEither.isRight) {
      emit(state.copyWith(isJobSearchEnabled: isJobSearchEnabledEither.right));
    }
  }
}
