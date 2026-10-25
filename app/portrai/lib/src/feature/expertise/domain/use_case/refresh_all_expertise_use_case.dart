import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/domain/exception/_exception.dart';
import 'package:portrai/src/feature/expertise/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RefreshAllExpertiseFailure extends BasicFailure {
  const RefreshAllExpertiseFailure({super.cause});
}

class RefreshAllExpertiseNetworkFailure extends RefreshAllExpertiseFailure {
  const RefreshAllExpertiseNetworkFailure({super.cause});
}

class RefreshAllExpertiseDataFailure extends RefreshAllExpertiseFailure {
  const RefreshAllExpertiseDataFailure({super.cause});
}

class RefreshAllExpertiseUnknownFailure extends RefreshAllExpertiseFailure {
  const RefreshAllExpertiseUnknownFailure({super.cause});
}

/// Replaces the cached expertise of the current locale with the latest one.
/// The cached expertise stays when the latest one cannot be loaded.
@register
class RefreshAllExpertiseUseCase
    extends BaseNoParamUseCase<void, RefreshAllExpertiseFailure> {
  RefreshAllExpertiseUseCase(this._repository);

  final ExpertiseRepository _repository;

  @protected
  @override
  Future<Either<RefreshAllExpertiseFailure, void>> execute() async {
    await _repository.refreshAllExpertise();
    return const Right(null);
  }

  @protected
  @override
  RefreshAllExpertiseFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ExpertiseNetworkException() || ExpertiseUnauthorizedException() =>
        RefreshAllExpertiseNetworkFailure(cause: e),
      ExpertiseNotFoundException() ||
      ExpertiseParsingException() ||
      ExpertiseCacheException() => RefreshAllExpertiseDataFailure(cause: e),
      _ => RefreshAllExpertiseUnknownFailure(cause: e),
    };
  }
}
