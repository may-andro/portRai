import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';
import 'package:portrai/src/feature/onboarding/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SaveUserFailure extends BasicFailure {
  const SaveUserFailure({super.cause});
}

@Localizable('errorGeneric')
class SaveUserUnknownFailure extends SaveUserFailure {
  const SaveUserUnknownFailure({super.cause});
}

@register
class SaveUserUseCase extends BaseUseCase<void, UserEntity, SaveUserFailure> {
  SaveUserUseCase(this._repository);

  final UserRepository _repository;

  @protected
  @override
  FutureOr<Either<SaveUserFailure, void>> execute(UserEntity user) async {
    await _repository.saveUser(user);
    return const Right(null);
  }

  @protected
  @override
  SaveUserFailure mapErrorToFailure(Object e, StackTrace st) =>
      SaveUserUnknownFailure(cause: e);
}
