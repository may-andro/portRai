import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';
import 'package:portrai/src/feature/onboarding/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

@register
class GetGuestUserUseCase
    extends BaseNoParamUseCase<GuestUserEntity?, NoFailure> {
  GetGuestUserUseCase(this._repository);

  final GuestUserRepository _repository;

  @protected
  @override
  FutureOr<Either<NoFailure, GuestUserEntity?>> execute() async =>
      Right(await _repository.getGuestUser());

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
