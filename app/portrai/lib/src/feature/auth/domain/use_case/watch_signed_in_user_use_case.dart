import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/repository/_repository.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

sealed class WatchSignedInUserFailure extends BasicFailure {
  const WatchSignedInUserFailure({super.cause});
}

class WatchSignedInUserUnknownFailure extends WatchSignedInUserFailure {
  const WatchSignedInUserUnknownFailure({super.cause});
}

/// The signed-in user, or null when nobody is signed in, first for the
/// restored session and then after every sign-in and sign-out.
@register
class WatchSignedInUserUseCase
    extends
        BaseNoParamStreamUseCase<AuthUserEntity?, WatchSignedInUserFailure> {
  WatchSignedInUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @protected
  @override
  Stream<AuthUserEntity?> execute() => _authRepository.signedInUserChanges;

  @protected
  @override
  WatchSignedInUserFailure mapErrorToFailure(Object e, StackTrace st) {
    return WatchSignedInUserUnknownFailure(cause: e);
  }
}
