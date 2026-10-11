import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant_availability.dart';
import 'package:use_case/use_case.dart';

@register
class IsLocalAssistantSupportedUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  IsLocalAssistantSupportedUseCase(this._availability);

  final LocalAssistantAvailability _availability;

  @protected
  @override
  Either<NoFailure, bool> execute() => Right(_availability.isSupported);

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
