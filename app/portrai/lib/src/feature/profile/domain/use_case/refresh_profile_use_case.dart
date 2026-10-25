import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/domain/exception/_exception.dart';
import 'package:portrai/src/feature/profile/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshProfileFailure extends BasicFailure {
  const RefreshProfileFailure({super.cause});
}

class RefreshProfileNetworkFailure extends RefreshProfileFailure {
  const RefreshProfileNetworkFailure({super.cause});
}

class RefreshProfileDataFailure extends RefreshProfileFailure {
  const RefreshProfileDataFailure({super.cause});
}

class RefreshProfileUnknownFailure extends RefreshProfileFailure {
  const RefreshProfileUnknownFailure({super.cause});
}

/// Replaces the cached profile of the current locale with the latest one.
/// The cached profile stays when the latest one cannot be loaded.
@register
class RefreshProfileUseCase
    extends BaseNoParamUseCase<void, RefreshProfileFailure> {
  RefreshProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @protected
  @override
  Future<Either<RefreshProfileFailure, void>> execute() async {
    await _repository.refreshProfile();
    return const Right(null);
  }

  @protected
  @override
  RefreshProfileFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ProfileNetworkException() ||
      ProfileUnauthorizedException() => RefreshProfileNetworkFailure(cause: e),
      ProfileNotFoundException() ||
      ProfileParsingException() ||
      ProfileCacheException() => RefreshProfileDataFailure(cause: e),
      _ => RefreshProfileUnknownFailure(cause: e),
    };
  }
}
