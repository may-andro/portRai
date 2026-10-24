import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/repository/_repository.dart';
import 'package:portrai/src/feature/user/user.dart';

/// The signed-in user, or null when nobody is signed in, first for the
/// restored session and then after every sign-in and sign-out.
@register
class GetSignedInUserStreamUseCase {
  GetSignedInUserStreamUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Stream<AuthUserEntity?> call() => _authRepository.signedInUserChanges;
}
