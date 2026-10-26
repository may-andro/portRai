import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';
import 'package:portrai/src/feature/asset_source/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class UpdateAssetSourceFailure extends BasicFailure {
  const UpdateAssetSourceFailure({super.cause});
}

@Localizable('errorGeneric')
class UpdateAssetSourceUnknownFailure extends UpdateAssetSourceFailure {
  const UpdateAssetSourceUnknownFailure({super.cause});
}

@register
class UpdateAssetSourceUseCase
    extends BaseUseCase<void, AssetSource, UpdateAssetSourceFailure> {
  UpdateAssetSourceUseCase(this._repository);

  final AssetSourceRepository _repository;

  @protected
  @override
  FutureOr<Either<UpdateAssetSourceFailure, void>> execute(
    AssetSource source,
  ) async {
    await _repository.setAssetSource(source);
    return const Right(null);
  }

  @protected
  @override
  UpdateAssetSourceFailure mapErrorToFailure(Object e, StackTrace st) =>
      UpdateAssetSourceUnknownFailure(cause: e);
}
