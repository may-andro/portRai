import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_event.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_state.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/tracking/_tracking.dart';

@register
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this._signInUseCase, this._trackingDelegate)
    : super(const SignInState()) {
    on<SignInStartedEvent>(_mapSignInStartedEventToState);
    on<SignInClickEvent>(_mapSignInClickEventToState);
  }

  final SignInUseCase _signInUseCase;
  final SignInTrackingDelegate _trackingDelegate;

  void _mapSignInStartedEventToState(
    SignInStartedEvent event,
    Emitter<SignInState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  Future<void> _mapSignInClickEventToState(
    SignInClickEvent event,
    Emitter<SignInState> emit,
  ) async {
    if (state.isSigningIn || state.isSignedIn) return;

    _trackingDelegate.trackSignInClick();
    emit(const SignInState(isSigningIn: true));

    final signInEither = await _signInUseCase(
      SignInParam(email: event.email, password: event.password),
    );
    if (signInEither.isLeft) {
      emit(SignInState(failure: signInEither.left));
      return;
    }
    emit(const SignInState(isSignedIn: true));
  }
}
