import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_event.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_state.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class SignInBloc extends Bloc<SignInEvent, SignInState>
    with ScreenTrackingBlocMixin<SignInEvent, SignInState> {
  SignInBloc(this._signInUseCase, this._trackingDelegate)
    : super(const SignInState()) {
    trackScreenViewOn<SignInStartedEvent>();
    on<SignInClickEvent>(_mapSignInClickEventToState);
  }

  final SignInUseCase _signInUseCase;
  final SignInTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapSignInClickEventToState(
    SignInClickEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state.isSigningIn || state.isSignedIn) return;

    _trackingDelegate.trackSignInClick();
    emit(state.copyWith(isSigningIn: true, clearFailure: true));

    final signInEither = await _signInUseCase(
      SignInParam(email: event.email, password: event.password),
    );
    if (signInEither.isLeft) {
      emit(state.copyWith(isSigningIn: false, failure: signInEither.left));
      return;
    }
    emit(state.copyWith(isSigningIn: false, isSignedIn: true));
  }
}
