import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchInternetConnectionFailure extends BasicFailure {
  const WatchInternetConnectionFailure({super.cause});
}

class WatchInternetConnectionUnknownFailure
    extends WatchInternetConnectionFailure {
  const WatchInternetConnectionUnknownFailure({super.cause});
}

@register
class WatchInternetConnectionUseCase
    extends BaseNoParamStreamUseCase<bool, WatchInternetConnectionFailure> {
  WatchInternetConnectionUseCase(this._connectivityRepository);

  final ConnectivityRepository _connectivityRepository;

  @protected
  @override
  Stream<bool> execute() => _connectivityRepository.watchConnection();

  @protected
  @override
  WatchInternetConnectionFailure mapErrorToFailure(Object e, StackTrace st) {
    return WatchInternetConnectionUnknownFailure(cause: e);
  }
}
