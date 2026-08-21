import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/domain/entity/_entity.dart';
import 'package:portrai/src/feature/service/domain/exception/_exception.dart';
import 'package:portrai/src/feature/service/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetServicesFailure extends BasicFailure {
  const GetServicesFailure({super.cause});
}

@Localizable('errorServicesNotFound')
class ServicesNotFoundFailure extends GetServicesFailure {
  const ServicesNotFoundFailure({super.cause});
}

@Localizable('errorServicesNetwork')
class ServicesNetworkFailure extends GetServicesFailure {
  const ServicesNetworkFailure({super.cause});
}

@Localizable('errorServicesData')
class ServicesDataFailure extends GetServicesFailure {
  const ServicesDataFailure({super.cause});
}

@Localizable('errorServicesUnauthorized')
class ServicesUnauthorizedFailure extends GetServicesFailure {
  const ServicesUnauthorizedFailure({super.cause});
}

@Localizable('errorServicesUnknown')
class ServicesUnknownFailure extends GetServicesFailure {
  const ServicesUnknownFailure({super.cause});
}

@register
class GetServicesUseCase
    extends BaseNoParamUseCase<List<ServiceEntity>, GetServicesFailure> {
  GetServicesUseCase(this._repository);

  final ServiceRepository _repository;

  @protected
  @override
  Future<Either<GetServicesFailure, List<ServiceEntity>>> execute() async {
    final expertiseList = await _repository.getServices();
    return Right(expertiseList);
  }

  @protected
  @override
  GetServicesFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      ServiceNotFoundException() => ServicesNotFoundFailure(cause: e),
      ServiceNetworkException() => ServicesNetworkFailure(cause: e),
      ServiceParsingException() => ServicesDataFailure(cause: e),
      ServiceUnauthorizedException() => ServicesUnauthorizedFailure(cause: e),
      ServiceCacheException() => ServicesDataFailure(cause: e),
      _ => ServicesUnknownFailure(cause: e),
    };
  }
}
