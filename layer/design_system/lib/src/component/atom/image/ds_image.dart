import 'package:design_system/assets/assets.gen.dart';
import 'package:flutter/material.dart';

/// Foundation class for accessing design system images
class DSImage {
  const DSImage._();

  /// Logo image asset path
  static String get logoPath => Assets.image.logo.path;
  static String get avatarPath => Assets.image.avatar.path;

  /// Logo image widget with customizable fit
  static Widget logo({BoxFit fit = BoxFit.contain}) {
    return Image.asset(
      Assets.image.logo.path,
      fit: fit,
      package: 'design_system',
    );
  }

  static Widget avatar({BoxFit fit = BoxFit.contain}) {
    return Image.asset(
      Assets.image.avatar.path,
      fit: fit,
      package: 'design_system',
    );
  }

  /// Direct access to the logo asset for advanced use cases
  static AssetGenImage get logoAsset => Assets.image.logo;
  static AssetGenImage get avatarAsset => Assets.image.avatar;
}
