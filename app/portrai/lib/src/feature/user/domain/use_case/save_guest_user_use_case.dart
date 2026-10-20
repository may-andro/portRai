import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/user/domain/entity/_entity.dart';
import 'package:portrai/src/feature/user/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SaveGuestUserFailure extends BasicFailure {
  const SaveGuestUserFailure({super.cause});
}

@Localizable('errorGeneric')
class SaveGuestUserUnknownFailure extends SaveGuestUserFailure {
  const SaveGuestUserUnknownFailure({super.cause});
}

@register
class SaveGuestUserUseCase
    extends BaseUseCase<void, GuestUserEntity, SaveGuestUserFailure> {
  SaveGuestUserUseCase(this._repository);

  final GuestUserRepository _repository;

  @protected
  @override
  FutureOr<Either<SaveGuestUserFailure, void>> execute(
    GuestUserEntity user,
  ) async {
    await _repository.saveGuestUser(user);
    return const Right(null);
  }

  @protected
  @override
  SaveGuestUserFailure mapErrorToFailure(Object e, StackTrace st) =>
      SaveGuestUserUnknownFailure(cause: e);
}
