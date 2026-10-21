import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_event.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_state.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@register
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(
    this._signInUseCase,
    this._getProfileUseCase,
    this._trackingDelegate,
  ) : super(const SignInState()) {
    on<SignInStartedEvent>(_mapSignInStartedEventToState);
    on<SignInClickEvent>(_mapSignInClickEventToState);
  }

  final SignInUseCase _signInUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final SignInTrackingDelegate _trackingDelegate;

  Future<void> _mapSignInStartedEventToState(
    SignInStartedEvent event,
    Emitter<SignInState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    final profileEither = await _getProfileUseCase();
    if (profileEither.isRight) {
      emit(state.copyWith(profile: profileEither.right));
    }
  }

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
