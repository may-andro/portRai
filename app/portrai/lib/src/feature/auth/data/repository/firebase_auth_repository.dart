import 'package:firebase/firebase.dart' as firebase;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

// A singleton, so the restored session is awaited only once per app run.
@RegisterSingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._authController, this._userMapper);

  final firebase.FbAuthController _authController;
  final AuthUserMapper _userMapper;
  bool _hasReceivedFirstAuthState = false;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _authController.signIn(email: email, password: password);
    } catch (error, stackTrace) {
      throw _toAuthException(error, stackTrace);
    }
  }

  @override
  Future<AuthUserEntity?> getSignedInUser() async {
    try {
      // The first event is the restored session, unlike `currentUser`, which
      // is still null right after start. Once it has arrived, `currentUser`
      // is up to date.
      final user = _hasReceivedFirstAuthState
          ? _authController.currentUser
          : await _authController.authStateChanges.first;
      _hasReceivedFirstAuthState = true;
      return user == null ? null : _userMapper.map(user);
    } catch (error, stackTrace) {
      throw _toAuthException(error, stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authController.signOut();
    } catch (error, stackTrace) {
      throw _toAuthException(error, stackTrace);
    }
  }

  static AuthException _toAuthException(Object error, StackTrace stackTrace) =>
      switch (error) {
        firebase.WrongPasswordException() ||
        firebase.UserNotFoundException() ||
        firebase.InvalidCredentialException() ||
        firebase.InvalidEmailException() ||
        firebase.UserDisabledException() => AuthInvalidCredentialsException(
          cause: error,
          stackTrace: stackTrace,
        ),
        firebase.TooManyRequestsException() => AuthTooManyRequestsException(
          cause: error,
          stackTrace: stackTrace,
        ),
        firebase.NetworkRequestFailedException() => AuthNetworkException(
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => AuthUnknownException(cause: error, stackTrace: stackTrace),
      };
}
