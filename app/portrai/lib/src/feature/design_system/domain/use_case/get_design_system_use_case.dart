import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

@register
class GetDesignSystemUseCase
    extends BaseNoParamUseCase<DesignSystem?, NoFailure> {
  GetDesignSystemUseCase(this._repository);

  final DesignSystemRepository _repository;

  @protected
  @override
  FutureOr<Either<NoFailure, DesignSystem?>> execute() async =>
      Right(await _repository.getDesignSystem());

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
