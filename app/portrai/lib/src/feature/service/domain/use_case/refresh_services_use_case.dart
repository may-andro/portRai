import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/domain/exception/_exception.dart';
import 'package:portrai/src/feature/service/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshServicesFailure extends BasicFailure {
  const RefreshServicesFailure({super.cause});
}

class RefreshServicesNetworkFailure extends RefreshServicesFailure {
  const RefreshServicesNetworkFailure({super.cause});
}

class RefreshServicesDataFailure extends RefreshServicesFailure {
  const RefreshServicesDataFailure({super.cause});
}

class RefreshServicesUnknownFailure extends RefreshServicesFailure {
  const RefreshServicesUnknownFailure({super.cause});
}

/// Replaces the cached services of the current locale with the latest ones.
/// The cached services stay when the latest ones cannot be loaded.
@register
class RefreshServicesUseCase
    extends BaseNoParamUseCase<void, RefreshServicesFailure> {
  RefreshServicesUseCase(this._repository);

  final ServiceRepository _repository;

  @protected
  @override
  Future<Either<RefreshServicesFailure, void>> execute() async {
    await _repository.refreshServices();
    return const Right(null);
  }

  @protected
  @override
  RefreshServicesFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ServiceNetworkException() ||
      ServiceUnauthorizedException() => RefreshServicesNetworkFailure(cause: e),
      ServiceNotFoundException() ||
      ServiceParsingException() ||
      ServiceCacheException() => RefreshServicesDataFailure(cause: e),
      _ => RefreshServicesUnknownFailure(cause: e),
    };
  }
}
