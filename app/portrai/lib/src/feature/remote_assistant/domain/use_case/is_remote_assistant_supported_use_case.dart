import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:use_case/use_case.dart';

@register
class IsRemoteAssistantSupportedUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  @protected
  @override
  Either<NoFailure, bool> execute() => Right(
    kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS,
  );

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
