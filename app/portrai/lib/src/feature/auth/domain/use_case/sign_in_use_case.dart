import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/exception/_exception.dart';
import 'package:portrai/src/feature/auth/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SignInFailure extends BasicFailure {
  const SignInFailure({super.cause});
}

@Localizable('errorSignInMissingCredentials')
class SignInMissingCredentialsFailure extends SignInFailure {
  const SignInMissingCredentialsFailure({super.cause});
}

@Localizable('errorSignInInvalidCredentials')
class SignInInvalidCredentialsFailure extends SignInFailure {
  const SignInInvalidCredentialsFailure({super.cause});
}

@Localizable('errorSignInTooManyRequests')
class SignInTooManyRequestsFailure extends SignInFailure {
  const SignInTooManyRequestsFailure({super.cause});
}

@Localizable('errorSignInNetwork')
class SignInNetworkFailure extends SignInFailure {
  const SignInNetworkFailure({super.cause});
}

@Localizable('errorSignInUnknown')
class SignInUnknownFailure extends SignInFailure {
  const SignInUnknownFailure({super.cause});
}

class SignInParam {
  const SignInParam({required this.email, required this.password});

  final String email;
  final String password;

  /// Use case params are logged, so this never prints the credentials.
  @override
  String toString() => 'SignInParam';
}

@register
class SignInUseCase extends BaseUseCase<void, SignInParam, SignInFailure> {
  SignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @protected
  @override
  FutureOr<Either<SignInFailure, void>> execute(SignInParam param) async {
    final email = param.email.trim();
    if (email.isEmpty || param.password.isEmpty) {
      return const Left(SignInMissingCredentialsFailure());
    }

    await _authRepository.signIn(email: email, password: param.password);
    return const Right(null);
  }

  @protected
  @override
  SignInFailure mapErrorToFailure(Object error, StackTrace stackTrace) =>
      switch (error) {
        AuthInvalidCredentialsException() => SignInInvalidCredentialsFailure(
          cause: error,
        ),
        AuthTooManyRequestsException() => SignInTooManyRequestsFailure(
          cause: error,
        ),
        AuthNetworkException() => SignInNetworkFailure(cause: error),
        _ => SignInUnknownFailure(cause: error),
      };
}
