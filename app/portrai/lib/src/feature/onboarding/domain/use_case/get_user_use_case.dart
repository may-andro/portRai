import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';
import 'package:portrai/src/feature/onboarding/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

@register
class GetUserUseCase extends BaseNoParamUseCase<UserEntity?, NoFailure> {
  GetUserUseCase(this._repository);

  final UserRepository _repository;

  @protected
  @override
  FutureOr<Either<NoFailure, UserEntity?>> execute() async =>
      Right(await _repository.getUser());

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
