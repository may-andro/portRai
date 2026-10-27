// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart' as _lottie;

class $AssetsImageGen {
  const $AssetsImageGen();

  /// File path: assets/image/avatar.png
  AssetGenImage get avatar => const AssetGenImage('assets/image/avatar.png');

  /// File path: assets/image/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/image/logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [avatar, logo];
}

class $AssetsLottieGen {
  const $AssetsLottieGen();

  /// File path: assets/lottie/binoculars.json
  LottieGenImage get binoculars =>
      const LottieGenImage('assets/lottie/binoculars.json');

  /// File path: assets/lottie/computer_window.json
  LottieGenImage get computerWindow =>
      const LottieGenImage('assets/lottie/computer_window.json');

  /// File path: assets/lottie/contact_us.json
  LottieGenImage get contactUs =>
      const LottieGenImage('assets/lottie/contact_us.json');

  /// File path: assets/lottie/developer_role.json
  LottieGenImage get developerRole =>
      const LottieGenImage('assets/lottie/developer_role.json');

  /// File path: assets/lottie/explorer_role.json
  LottieGenImage get explorerRole =>
      const LottieGenImage('assets/lottie/explorer_role.json');

  /// File path: assets/lottie/folder.json
  LottieGenImage get folder =>
      const LottieGenImage('assets/lottie/folder.json');

  /// File path: assets/lottie/github.json
  LottieGenImage get github =>
      const LottieGenImage('assets/lottie/github.json');

  /// File path: assets/lottie/globe.json
  LottieGenImage get globe => const LottieGenImage('assets/lottie/globe.json');

  /// File path: assets/lottie/graduation_hat.json
  LottieGenImage get graduationHat =>
      const LottieGenImage('assets/lottie/graduation_hat.json');

  /// File path: assets/lottie/hero_orbs.json
  LottieGenImage get heroOrbs =>
      const LottieGenImage('assets/lottie/hero_orbs.json');

  /// File path: assets/lottie/hero_orbs_mobile.json
  LottieGenImage get heroOrbsMobile =>
      const LottieGenImage('assets/lottie/hero_orbs_mobile.json');

  /// File path: assets/lottie/language.json
  LottieGenImage get language =>
      const LottieGenImage('assets/lottie/language.json');

  /// File path: assets/lottie/linkedin.json
  LottieGenImage get linkedin =>
      const LottieGenImage('assets/lottie/linkedin.json');

  /// File path: assets/lottie/loader.json
  LottieGenImage get loader =>
      const LottieGenImage('assets/lottie/loader.json');

  /// File path: assets/lottie/logo.json
  LottieGenImage get logo => const LottieGenImage('assets/lottie/logo.json');

  /// File path: assets/lottie/map_pin.json
  LottieGenImage get mapPin =>
      const LottieGenImage('assets/lottie/map_pin.json');

  /// File path: assets/lottie/medal.json
  LottieGenImage get medal => const LottieGenImage('assets/lottie/medal.json');

  /// File path: assets/lottie/orbit.json
  LottieGenImage get orbit => const LottieGenImage('assets/lottie/orbit.json');

  /// File path: assets/lottie/paper_plane.json
  LottieGenImage get paperPlane =>
      const LottieGenImage('assets/lottie/paper_plane.json');

  /// File path: assets/lottie/pin_pulse.json
  LottieGenImage get pinPulse =>
      const LottieGenImage('assets/lottie/pin_pulse.json');

  /// File path: assets/lottie/recruiter_role.json
  LottieGenImage get recruiterRole =>
      const LottieGenImage('assets/lottie/recruiter_role.json');

  /// File path: assets/lottie/resume.json
  LottieGenImage get resume =>
      const LottieGenImage('assets/lottie/resume.json');

  /// File path: assets/lottie/sign_in.json
  LottieGenImage get signIn =>
      const LottieGenImage('assets/lottie/sign_in.json');

  /// File path: assets/lottie/talent_search.json
  LottieGenImage get talentSearch =>
      const LottieGenImage('assets/lottie/talent_search.json');

  /// File path: assets/lottie/tech_stack.json
  LottieGenImage get techStack =>
      const LottieGenImage('assets/lottie/tech_stack.json');

  /// File path: assets/lottie/website.json
  LottieGenImage get website =>
      const LottieGenImage('assets/lottie/website.json');

  /// List of all assets
  List<LottieGenImage> get values => [
    binoculars,
    computerWindow,
    contactUs,
    developerRole,
    explorerRole,
    folder,
    github,
    globe,
    graduationHat,
    heroOrbs,
    heroOrbsMobile,
    language,
    linkedin,
    loader,
    logo,
    mapPin,
    medal,
    orbit,
    paperPlane,
    pinPulse,
    recruiterRole,
    resume,
    signIn,
    talentSearch,
    techStack,
    website,
  ];
}

abstract final class Assets {
  static const $AssetsImageGen image = $AssetsImageGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
    _lottie.LottieDecoder? decoder,
    _lottie.RenderCache? renderCache,
    bool? backgroundLoading,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
      decoder: decoder,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
