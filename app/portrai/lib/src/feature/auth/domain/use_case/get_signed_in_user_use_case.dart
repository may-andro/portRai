import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/domain/entity/_entity.dart';
import 'package:portrai/src/feature/auth/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetSignedInUserFailure extends BasicFailure {
  const GetSignedInUserFailure({super.cause});
}

class GetSignedInUserUnknownFailure extends GetSignedInUserFailure {
  const GetSignedInUserUnknownFailure({super.cause});
}

/// Resolves to the signed-in user, or null when nobody is signed in.
@register
class GetSignedInUserUseCase
    extends BaseNoParamUseCase<AuthUserEntity?, GetSignedInUserFailure> {
  GetSignedInUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @protected
  @override
  FutureOr<Either<GetSignedInUserFailure, AuthUserEntity?>> execute() async =>
      Right(await _authRepository.getSignedInUser());

  @protected
  @override
  GetSignedInUserFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => GetSignedInUserUnknownFailure(cause: error);
}
