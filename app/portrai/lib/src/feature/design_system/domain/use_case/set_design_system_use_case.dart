import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SetDesignSystemFailure extends BasicFailure {
  const SetDesignSystemFailure({super.cause});
}

@Localizable('errorGeneric')
class SetDesignSystemUnknownFailure extends SetDesignSystemFailure {
  const SetDesignSystemUnknownFailure({super.cause});
}

@register
class SetDesignSystemUseCase
    extends BaseUseCase<void, DesignSystem, SetDesignSystemFailure> {
  SetDesignSystemUseCase(this._repository);

  final DesignSystemRepository _repository;

  @protected
  @override
  FutureOr<Either<SetDesignSystemFailure, void>> execute(
    DesignSystem designSystem,
  ) async {
    await _repository.setDesignSystem(designSystem);
    return const Right(null);
  }

  @protected
  @override
  SetDesignSystemFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => SetDesignSystemUnknownFailure(cause: error);
}
