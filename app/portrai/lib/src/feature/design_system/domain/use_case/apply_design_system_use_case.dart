import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/reset_design_system_use_case.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/select_design_system_use_case.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/set_design_system_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class ApplyDesignSystemFailure extends BasicFailure {
  const ApplyDesignSystemFailure({super.cause});
}

@Localizable('errorGeneric')
class ApplyDesignSystemUnknownFailure extends ApplyDesignSystemFailure {
  const ApplyDesignSystemUnknownFailure({super.cause});
}

/// Makes the given design system the one the app starts with. Choosing the
/// current month's design system clears the saved choice instead, so the app
/// keeps following the month.
@register
class ApplyDesignSystemUseCase
    extends BaseUseCase<void, DesignSystem, ApplyDesignSystemFailure> {
  ApplyDesignSystemUseCase(
    this._selectDesignSystemUseCase,
    this._setDesignSystemUseCase,
    this._resetDesignSystemUseCase,
  );

  final SelectDesignSystemUseCase _selectDesignSystemUseCase;
  final SetDesignSystemUseCase _setDesignSystemUseCase;
  final ResetDesignSystemUseCase _resetDesignSystemUseCase;

  @protected
  @override
  FutureOr<Either<ApplyDesignSystemFailure, void>> execute(
    DesignSystem designSystem,
  ) async {
    final monthlyDesignSystemEither = await _selectDesignSystemUseCase();
    if (monthlyDesignSystemEither.isRight &&
        monthlyDesignSystemEither.right == designSystem) {
      final resetDesignSystemEither = await _resetDesignSystemUseCase();
      if (resetDesignSystemEither.isLeft) {
        return Left(
          ApplyDesignSystemUnknownFailure(cause: resetDesignSystemEither.left),
        );
      }
      return const Right(null);
    }

    final setDesignSystemEither = await _setDesignSystemUseCase(designSystem);
    if (setDesignSystemEither.isLeft) {
      return Left(
        ApplyDesignSystemUnknownFailure(cause: setDesignSystemEither.left),
      );
    }
    return const Right(null);
  }

  @protected
  @override
  ApplyDesignSystemFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => ApplyDesignSystemUnknownFailure(cause: error);
}
