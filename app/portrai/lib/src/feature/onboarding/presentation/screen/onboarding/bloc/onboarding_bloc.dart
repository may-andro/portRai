import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_event.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_state.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/tracking/_tracking.dart';

@register
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._saveUserUseCase, this._trackingDelegate)
    : super(const OnboardingState()) {
    on<OnboardingStartedEvent>(_mapOnboardingStartedEventToState);
    on<RoleSelectedClickEvent>(_mapRoleSelectedClickEventToState);
  }

  final SaveUserUseCase _saveUserUseCase;
  final OnboardingTrackingDelegate _trackingDelegate;

  void _mapOnboardingStartedEventToState(
    OnboardingStartedEvent event,
    Emitter<OnboardingState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  Future<void> _mapRoleSelectedClickEventToState(
    RoleSelectedClickEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.isSaving || state.isCompleted) return;

    _trackingDelegate.trackRoleSelection(event.role.name);
    emit(OnboardingState(selectedRole: event.role));

    final saveUserEither = await _saveUserUseCase(UserEntity(role: event.role));
    if (saveUserEither.isLeft) {
      emit(OnboardingState(failure: saveUserEither.left));
      return;
    }
    emit(OnboardingState(selectedRole: event.role, isCompleted: true));
  }
}
