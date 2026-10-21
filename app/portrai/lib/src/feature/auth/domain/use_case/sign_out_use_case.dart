import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/exception/_exception.dart';
import 'package:portrai/src/feature/auth/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SignOutFailure extends BasicFailure {
  const SignOutFailure({super.cause});
}

@Localizable('errorSignOutNetwork')
class SignOutNetworkFailure extends SignOutFailure {
  const SignOutNetworkFailure({super.cause});
}

@Localizable('errorSignOutUnknown')
class SignOutUnknownFailure extends SignOutFailure {
  const SignOutUnknownFailure({super.cause});
}

@register
class SignOutUseCase extends BaseNoParamUseCase<void, SignOutFailure> {
  SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @protected
  @override
  FutureOr<Either<SignOutFailure, void>> execute() async {
    await _authRepository.signOut();
    return const Right(null);
  }

  @protected
  @override
  SignOutFailure mapErrorToFailure(Object error, StackTrace stackTrace) =>
      switch (error) {
        AuthNetworkException() => SignOutNetworkFailure(cause: error),
        _ => SignOutUnknownFailure(cause: error),
      };
}
