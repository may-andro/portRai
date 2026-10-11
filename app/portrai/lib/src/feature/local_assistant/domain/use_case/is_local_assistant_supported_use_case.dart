import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:use_case/use_case.dart';

@register
class IsLocalAssistantSupportedUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  @protected
  @override
  Either<NoFailure, bool> execute() => const Right(!kIsWeb);

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
