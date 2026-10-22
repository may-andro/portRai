import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_event.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_state.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/tracking/_tracking.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState>
    with ScreenTrackingBlocMixin<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._saveGuestUserUseCase, this._trackingDelegate)
    : super(const OnboardingState()) {
    trackScreenViewOn<OnboardingStartedEvent>();
    on<RoleSelectedClickEvent>(_mapRoleSelectedClickEventToState);
  }

  final SaveGuestUserUseCase _saveGuestUserUseCase;
  final OnboardingTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapRoleSelectedClickEventToState(
    RoleSelectedClickEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.isSaving || state.isCompleted) return;

    _trackingDelegate.trackRoleSelection(event.role.name);
    emit(OnboardingState(selectedRole: event.role));

    final saveGuestUserEither = await _saveGuestUserUseCase(
      GuestUserEntity(role: event.role),
    );
    if (saveGuestUserEither.isLeft) {
      emit(OnboardingState(failure: saveGuestUserEither.left));
      return;
    }
    emit(OnboardingState(selectedRole: event.role, isCompleted: true));
  }
}
