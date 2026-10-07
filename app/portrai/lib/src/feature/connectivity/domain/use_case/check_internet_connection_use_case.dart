import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class CheckInternetConnectionFailure extends BasicFailure {
  const CheckInternetConnectionFailure({super.cause});
}

class CheckInternetConnectionUnknownFailure
    extends CheckInternetConnectionFailure {
  const CheckInternetConnectionUnknownFailure({super.cause});
}

@register
class CheckInternetConnectionUseCase
    extends BaseNoParamUseCase<bool, CheckInternetConnectionFailure> {
  CheckInternetConnectionUseCase(this._connectivityRepository);

  final ConnectivityRepository _connectivityRepository;

  @protected
  @override
  FutureOr<Either<CheckInternetConnectionFailure, bool>> execute() async {
    return Right(await _connectivityRepository.isConnected());
  }

  @protected
  @override
  CheckInternetConnectionFailure mapErrorToFailure(Object e, StackTrace st) {
    return CheckInternetConnectionUnknownFailure(cause: e);
  }
}
