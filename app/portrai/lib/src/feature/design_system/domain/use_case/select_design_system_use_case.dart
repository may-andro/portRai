import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:use_case/use_case.dart';

/// Selects the festival design system assigned to the current month.
@register
class SelectDesignSystemUseCase
    extends BaseNoParamUseCase<DesignSystem, NoFailure> {
  /// The design system of each month, keyed by [DateTime.month].
  static const designSystemByMonth = <int, DesignSystem>{
    DateTime.january: DesignSystem.hogmanay,
    DateTime.february: DesignSystem.carnival,
    DateTime.march: DesignSystem.holi,
    DateTime.april: DesignSystem.sakura,
    DateTime.may: DesignSystem.beltane,
    DateTime.june: DesignSystem.hogeras,
    DateTime.july: DesignSystem.obon,
    DateTime.august: DesignSystem.pachamama,
    DateTime.september: DesignSystem.chuseok,
    DateTime.october: DesignSystem.halloween,
    DateTime.november: DesignSystem.diwali,
    DateTime.december: DesignSystem.xmas,
  };

  @protected
  @override
  FutureOr<Either<NoFailure, DesignSystem>> execute() =>
      Right(designSystemByMonth[DateTime.now().month]!);

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
