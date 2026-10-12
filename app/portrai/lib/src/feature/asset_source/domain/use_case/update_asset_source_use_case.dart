import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';
import 'package:portrai/src/feature/asset_source/domain/repository/_repository.dart';
import 'package:portrai/src/feature/asset_source/domain/use_case/asset_source_failure.dart';
import 'package:use_case/use_case.dart';

@register
class UpdateAssetSourceUseCase
    extends BaseUseCase<void, AssetSource, AssetSourceFailure> {
  UpdateAssetSourceUseCase(this._repository);

  final AssetSourceRepository _repository;

  @protected
  @override
  FutureOr<Either<AssetSourceFailure, void>> execute(AssetSource source) async {
    await _repository.setAssetSource(source);
    return const Right(null);
  }

  @protected
  @override
  AssetSourceFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssetSourceFailure(cause: e);
}
