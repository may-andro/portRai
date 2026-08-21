import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/domain/entity/_entity.dart';
import 'package:portrai/src/feature/profile/domain/exception/_exception.dart';
import 'package:portrai/src/feature/profile/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetProfileFailure extends BasicFailure {
  const GetProfileFailure({super.cause});
}

@Localizable('errorProfileNotFound')
class ProfileNotFoundFailure extends GetProfileFailure {
  const ProfileNotFoundFailure({super.cause});
}

@Localizable('errorProfileNetwork')
class ProfileNetworkFailure extends GetProfileFailure {
  const ProfileNetworkFailure({super.cause});
}

@Localizable('errorProfileData')
class ProfileDataFailure extends GetProfileFailure {
  const ProfileDataFailure({super.cause});
}

@Localizable('errorProfileUnauthorized')
class ProfileUnauthorizedFailure extends GetProfileFailure {
  const ProfileUnauthorizedFailure({super.cause});
}

@Localizable('errorProfileUnknown')
class ProfileUnknownFailure extends GetProfileFailure {
  const ProfileUnknownFailure({super.cause});
}

@register
class GetProfileUseCase
    extends BaseNoParamUseCase<ProfileEntity, GetProfileFailure> {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @protected
  @override
  Future<Either<GetProfileFailure, ProfileEntity>> execute() async {
    final profile = await _repository.getProfile();
    return Right(profile);
  }

  @protected
  @override
  GetProfileFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ProfileNotFoundException() => ProfileNotFoundFailure(cause: e),
      ProfileNetworkException() => ProfileNetworkFailure(cause: e),
      ProfileParsingException() => ProfileDataFailure(cause: e),
      ProfileUnauthorizedException() => ProfileUnauthorizedFailure(cause: e),
      ProfileCacheException() => ProfileDataFailure(cause: e),
      _ => ProfileUnknownFailure(cause: e),
    };
  }
}
