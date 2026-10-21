import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class IsJobSearchEnabledFailure extends BasicFailure {
  const IsJobSearchEnabledFailure({super.cause});
}

@Localizable('errorJobOpeningsSignedOut')
class IsJobSearchEnabledSignedOutFailure extends IsJobSearchEnabledFailure {
  const IsJobSearchEnabledSignedOutFailure({super.cause});
}

@Localizable('errorJobSearchUnavailable')
class IsJobSearchEnabledUnknownFailure extends IsJobSearchEnabledFailure {
  const IsJobSearchEnabledUnknownFailure({super.cause});
}

/// Whether the weekly job search includes the signed-in user.
@register
class IsJobSearchEnabledUseCase
    extends BaseNoParamUseCase<bool, IsJobSearchEnabledFailure> {
  IsJobSearchEnabledUseCase(
    this._getSignedInUserUseCase,
    this._jobOpeningRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final JobOpeningRepository _jobOpeningRepository;

  @protected
  @override
  FutureOr<Either<IsJobSearchEnabledFailure, bool>> execute() async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(
        IsJobSearchEnabledUnknownFailure(cause: signedInUserEither.left),
      );
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(IsJobSearchEnabledSignedOutFailure());
    }

    return Right(
      await _jobOpeningRepository.isJobSearchEnabled(signedInUser.id),
    );
  }

  @protected
  @override
  IsJobSearchEnabledFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => IsJobSearchEnabledUnknownFailure(cause: error);
}
