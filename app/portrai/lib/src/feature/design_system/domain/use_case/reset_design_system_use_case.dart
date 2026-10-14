import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class ResetDesignSystemFailure extends BasicFailure {
  const ResetDesignSystemFailure({super.cause});
}

@Localizable('errorGeneric')
class ResetDesignSystemUnknownFailure extends ResetDesignSystemFailure {
  const ResetDesignSystemUnknownFailure({super.cause});
}

@register
class ResetDesignSystemUseCase
    extends BaseNoParamUseCase<void, ResetDesignSystemFailure> {
  ResetDesignSystemUseCase(this._repository);

  final DesignSystemRepository _repository;

  @protected
  @override
  FutureOr<Either<ResetDesignSystemFailure, void>> execute() async {
    await _repository.clearDesignSystem();
    return const Right(null);
  }

  @protected
  @override
  ResetDesignSystemFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => ResetDesignSystemUnknownFailure(cause: error);
}
