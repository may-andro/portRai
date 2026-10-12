import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/domain/entity/_entity.dart';
import 'package:portrai/src/feature/asset_source/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

/// Falls back to [AssetSource.real] when the stored selection can't be read.
@register
class GetAssetSourceUseCase extends BaseNoParamUseCase<AssetSource, NoFailure> {
  GetAssetSourceUseCase(this._repository);

  final AssetSourceRepository _repository;

  @protected
  @override
  FutureOr<Either<NoFailure, AssetSource>> execute() async {
    try {
      return Right(await _repository.getAssetSource());
    } catch (_) {
      return const Right(AssetSource.real);
    }
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
