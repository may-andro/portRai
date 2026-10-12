import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:use_case/use_case.dart';

class MockGetAssetSourceUseCase extends Mock implements GetAssetSourceUseCase {}

extension MockGetAssetSourceUseCaseStub on MockGetAssetSourceUseCase {
  void stubCall(AssetSource source) {
    when(() => this()).thenAnswer((_) => Right<NoFailure, AssetSource>(source));
  }
}
