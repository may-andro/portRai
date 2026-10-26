import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_event.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_state.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/tracking/_tracking.dart';

@register
class JobOpeningsBloc extends Bloc<JobOpeningsEvent, JobOpeningsState> {
  JobOpeningsBloc(
    this._getJobOpeningsUseCase,
    this._signOutUseCase,
    this._trackingDelegate,
  ) : super(const JobOpeningsState()) {
    on<JobOpeningsStartedEvent>(_mapJobOpeningsStartedEventToState);
    on<JobOpeningsRetryClickEvent>(_mapJobOpeningsRetryClickEventToState);
    on<JobOpeningClickEvent>(_mapJobOpeningClickEventToState);
    on<JobOpeningsSearchChangedEvent>(_mapJobOpeningsSearchChangedEventToState);
    on<JobOpeningsFilterClickEvent>(_mapJobOpeningsFilterClickEventToState);
    on<JobOpeningsClearFiltersClickEvent>(
      _mapJobOpeningsClearFiltersClickEventToState,
    );
    on<SignOutClickEvent>(_mapSignOutClickEventToState);
  }

  final GetJobOpeningsUseCase _getJobOpeningsUseCase;
  final SignOutUseCase _signOutUseCase;
  final JobOpeningsTrackingDelegate _trackingDelegate;

  Future<void> _mapJobOpeningsStartedEventToState(
    JobOpeningsStartedEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await _loadJobOpenings(emit);
  }

  Future<void> _mapJobOpeningsRetryClickEventToState(
    JobOpeningsRetryClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) async {
    await _loadJobOpenings(emit);
  }

  void _mapJobOpeningClickEventToState(
    JobOpeningClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) {
    _trackingDelegate.trackJobOpeningClick();
  }

  void _mapJobOpeningsSearchChangedEventToState(
    JobOpeningsSearchChangedEvent event,
    Emitter<JobOpeningsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.searchQuery));
  }

  void _mapJobOpeningsFilterClickEventToState(
    JobOpeningsFilterClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) {
    final filter = event.filter;
    final isSelected = !state.filters.contains(filter);
    if (isSelected) _trackingDelegate.trackFilterSelection(filter.name);
    emit(
      state.copyWith(
        filters: isSelected
            ? {...state.filters, filter}
            : ({...state.filters}..remove(filter)),
      ),
    );
  }

  void _mapJobOpeningsClearFiltersClickEventToState(
    JobOpeningsClearFiltersClickEvent event,
    Emitter<JobOpeningsState> emit,
  ) {
    _trackingDelegate.trackClearFiltersClick();
    emit(state.copyWith(searchQuery: '', filters: const {}));
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
}
