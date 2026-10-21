import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/entity/_entity.dart';
import 'package:portrai/src/feature/job_opening/domain/exception/_exception.dart';
import 'package:portrai/src/feature/job_opening/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetJobOpeningsFailure extends BasicFailure {
  const GetJobOpeningsFailure({super.cause});
}

@Localizable('errorJobOpeningsSignedOut')
class GetJobOpeningsSignedOutFailure extends GetJobOpeningsFailure {
  const GetJobOpeningsSignedOutFailure({super.cause});
}

@Localizable('errorJobOpeningsPermissionDenied')
class GetJobOpeningsPermissionDeniedFailure extends GetJobOpeningsFailure {
  const GetJobOpeningsPermissionDeniedFailure({super.cause});
}

@Localizable('errorJobOpeningsNetwork')
class GetJobOpeningsNetworkFailure extends GetJobOpeningsFailure {
  const GetJobOpeningsNetworkFailure({super.cause});
}

@Localizable('errorJobOpeningsUnknown')
class GetJobOpeningsUnknownFailure extends GetJobOpeningsFailure {
  const GetJobOpeningsUnknownFailure({super.cause});
}

/// The signed-in user's job openings, best fit first and then newest first.
@register
class GetJobOpeningsUseCase
    extends BaseNoParamUseCase<List<JobOpeningEntity>, GetJobOpeningsFailure> {
  GetJobOpeningsUseCase(
    this._getSignedInUserUseCase,
    this._jobOpeningRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final JobOpeningRepository _jobOpeningRepository;

  @protected
  @override
  FutureOr<Either<GetJobOpeningsFailure, List<JobOpeningEntity>>>
  execute() async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(GetJobOpeningsUnknownFailure(cause: signedInUserEither.left));
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(GetJobOpeningsSignedOutFailure());
    }

    final jobOpenings = await _jobOpeningRepository.getJobOpenings(
      signedInUser.id,
    );
    return Right(
      [...jobOpenings]..sort(
        (first, second) => second.score != first.score
            ? second.score.compareTo(first.score)
            : second.publishedAt.compareTo(first.publishedAt),
      ),
    );
  }

  @protected
  @override
  GetJobOpeningsFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    JobOpeningPermissionDeniedException() =>
      GetJobOpeningsPermissionDeniedFailure(cause: error),
    JobOpeningNetworkException() => GetJobOpeningsNetworkFailure(cause: error),
    _ => GetJobOpeningsUnknownFailure(cause: error),
  };
}
