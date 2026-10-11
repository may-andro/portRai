import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant_availability.dart';
import 'package:use_case/use_case.dart';

@register
class IsRemoteAssistantSupportedUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  IsRemoteAssistantSupportedUseCase(this._availability);

  final RemoteAssistantAvailability _availability;

  @protected
  @override
  Either<NoFailure, bool> execute() => Right(_availability.isSupported);

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
