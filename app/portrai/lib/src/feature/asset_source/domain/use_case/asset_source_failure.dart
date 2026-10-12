import 'package:use_case/use_case.dart';

sealed class AssetSourceFailure extends BasicFailure {
  const AssetSourceFailure({super.cause});
}

@Localizable('errorGeneric')
class UnknownAssetSourceFailure extends AssetSourceFailure {
  const UnknownAssetSourceFailure({super.cause});
}
