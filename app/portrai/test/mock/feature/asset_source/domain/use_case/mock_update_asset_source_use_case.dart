import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/asset_source/domain/use_case/asset_source_failure.dart';
import 'package:use_case/use_case.dart';

class MockUpdateAssetSourceUseCase extends Mock
    implements UpdateAssetSourceUseCase {}

extension MockUpdateAssetSourceUseCaseStub on MockUpdateAssetSourceUseCase {
  void registerFallbacks() => registerFallbackValue(AssetSource.real);

  void stubCall(Either<AssetSourceFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
