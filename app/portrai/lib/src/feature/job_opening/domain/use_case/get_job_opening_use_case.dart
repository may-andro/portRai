import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/entity/_entity.dart';
import 'package:portrai/src/feature/job_opening/domain/exception/_exception.dart';
import 'package:portrai/src/feature/job_opening/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetJobOpeningFailure extends BasicFailure {
  const GetJobOpeningFailure({super.cause});
}

@Localizable('errorJobOpeningsSignedOut')
class GetJobOpeningSignedOutFailure extends GetJobOpeningFailure {
  const GetJobOpeningSignedOutFailure({super.cause});
}

/// The opening expired or the link points at no opening.
@Localizable('errorJobOpeningNotFound')
class GetJobOpeningNotFoundFailure extends GetJobOpeningFailure {
  const GetJobOpeningNotFoundFailure({super.cause});
}

@Localizable('errorJobOpeningsPermissionDenied')
class GetJobOpeningPermissionDeniedFailure extends GetJobOpeningFailure {
  const GetJobOpeningPermissionDeniedFailure({super.cause});
}

@Localizable('errorJobOpeningsNetwork')
class GetJobOpeningNetworkFailure extends GetJobOpeningFailure {
  const GetJobOpeningNetworkFailure({super.cause});
}

@Localizable('errorJobOpeningsUnknown')
class GetJobOpeningUnknownFailure extends GetJobOpeningFailure {
  const GetJobOpeningUnknownFailure({super.cause});
}

/// One of the signed-in user's job openings, by its ID.
@register
class GetJobOpeningUseCase
    extends BaseUseCase<JobOpeningEntity, String, GetJobOpeningFailure> {
  GetJobOpeningUseCase(
    this._getSignedInUserUseCase,
    this._jobOpeningRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final JobOpeningRepository _jobOpeningRepository;

  @protected
  @override
  FutureOr<Either<GetJobOpeningFailure, JobOpeningEntity>> execute(
    String id,
  ) async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(GetJobOpeningUnknownFailure(cause: signedInUserEither.left));
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(GetJobOpeningSignedOutFailure());
    }

    return Right(
      await _jobOpeningRepository.getJobOpening(
        userId: signedInUser.id,
        id: id,
      ),
    );
  }

  @protected
  @override
  GetJobOpeningFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    JobOpeningNotFoundException() => GetJobOpeningNotFoundFailure(cause: error),
    JobOpeningPermissionDeniedException() =>
      GetJobOpeningPermissionDeniedFailure(cause: error),
    JobOpeningNetworkException() => GetJobOpeningNetworkFailure(cause: error),
    _ => GetJobOpeningUnknownFailure(cause: error),
  };
}
