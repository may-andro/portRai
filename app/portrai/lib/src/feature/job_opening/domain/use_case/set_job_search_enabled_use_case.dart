import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/exception/_exception.dart';
import 'package:portrai/src/feature/job_opening/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class SetJobSearchEnabledFailure extends BasicFailure {
  const SetJobSearchEnabledFailure({super.cause});
}

@Localizable('errorJobOpeningsSignedOut')
class SetJobSearchEnabledSignedOutFailure extends SetJobSearchEnabledFailure {
  const SetJobSearchEnabledSignedOutFailure({super.cause});
}

@Localizable('errorJobSearchPermissionDenied')
class SetJobSearchEnabledPermissionDeniedFailure
    extends SetJobSearchEnabledFailure {
  const SetJobSearchEnabledPermissionDeniedFailure({super.cause});
}

@Localizable('errorJobSearchNetwork')
class SetJobSearchEnabledNetworkFailure extends SetJobSearchEnabledFailure {
  const SetJobSearchEnabledNetworkFailure({super.cause});
}

@Localizable('errorJobSearchUnknown')
class SetJobSearchEnabledUnknownFailure extends SetJobSearchEnabledFailure {
  const SetJobSearchEnabledUnknownFailure({super.cause});
}

/// Turns the weekly job search on or off for the signed-in user.
@register
class SetJobSearchEnabledUseCase
    extends BaseUseCase<void, bool, SetJobSearchEnabledFailure> {
  SetJobSearchEnabledUseCase(
    this._getSignedInUserUseCase,
    this._jobOpeningRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final JobOpeningRepository _jobOpeningRepository;

  @protected
  @override
  FutureOr<Either<SetJobSearchEnabledFailure, void>> execute(
    bool isEnabled,
  ) async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(
        SetJobSearchEnabledUnknownFailure(cause: signedInUserEither.left),
      );
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(SetJobSearchEnabledSignedOutFailure());
    }

    await _jobOpeningRepository.setJobSearchEnabled(
      userId: signedInUser.id,
      isEnabled: isEnabled,
    );
    return const Right(null);
  }

  @protected
  @override
  SetJobSearchEnabledFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    JobOpeningPermissionDeniedException() =>
      SetJobSearchEnabledPermissionDeniedFailure(cause: error),
    JobOpeningNetworkException() => SetJobSearchEnabledNetworkFailure(
      cause: error,
    ),
    _ => SetJobSearchEnabledUnknownFailure(cause: error),
  };
}
