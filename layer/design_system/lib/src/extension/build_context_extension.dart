import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:design_system/src/component/molecule/molecule.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:design_system/src/theme/ds_theme.dart';
import 'package:design_system/src/theme/ds_theme_widget.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  DSTheme get theme => DSThemeWidget.of(this);

  DSColorPalette get colorPalette => theme.colorPalette;

  DSTypography get typography => theme.typography;

  DSDimen get dimen => theme.dimen;

  double space({double factor = 1}) {
    double deviceFactor = 0;
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        deviceFactor = 0;
      case DSDeviceResolution.tablet:
        deviceFactor = 4;
      case DSDeviceResolution.desktop:
        deviceFactor = 8;
    }
    return factor * (theme.dimen.grid.value + deviceFactor) * textScaleFactor;
  }

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  Size get size => MediaQuery.sizeOf(this);

  double get width => size.width;

  double get height => size.height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  double get shortestSide => size.shortestSide;

  Brightness get platformBrightness => MediaQuery.platformBrightnessOf(this);

  bool get isDarkMode => platformBrightness == Brightness.dark;

  double get textScaleFactor => MediaQuery.textScalerOf(this).scale(10) / 10;

  bool get isMobile => deviceResolution.isMobile;

  bool get isTablet => deviceResolution.isTablet;

  bool get isDesktop => deviceResolution.isDesktop;

  DSDeviceResolution get deviceResolution {
    switch (getWindowType(this)) {
      case AdaptiveWindowType.xsmall:
        return DSDeviceResolution.mobile;
      case AdaptiveWindowType.small:
        return DSDeviceResolution.tablet;
      case AdaptiveWindowType.medium:
        return DSDeviceResolution.desktop;
      case AdaptiveWindowType.large:
        return DSDeviceResolution.desktop;
      case AdaptiveWindowType.xlarge:
        return DSDeviceResolution.desktop;
      default:
        return DSDeviceResolution.mobile;
    }
  }

  DSDeviceWidthResolution get deviceWidth {
    switch (getWindowType(this)) {
      case AdaptiveWindowType.xsmall:
        return DSDeviceWidthResolution.xs;
      case AdaptiveWindowType.small:
        return DSDeviceWidthResolution.s;
      case AdaptiveWindowType.medium:
        return DSDeviceWidthResolution.m;
      case AdaptiveWindowType.large:
        return DSDeviceWidthResolution.l;
      case AdaptiveWindowType.xlarge:
        return DSDeviceWidthResolution.xl;
      default:
        return DSDeviceWidthResolution.s;
    }
  }

  double getTextWidth(String text, DSTextStyle textStyle) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle.textStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(this),
    )..layout();
    final textWidth = textPainter.maxIntrinsicWidth;
    textPainter.dispose();
    return textWidth;
  }

  double getTextHeight(DSTextStyle textStyle, int lines) {
    return _singleLineHeightOf(
          textStyle.textStyle,
          MediaQuery.textScalerOf(this),
        ) *
        lines;
  }

  void showSnackBar({required DSSnackBar snackBar}) {
    ScaffoldMessenger.of(this).showSnackBar(snackBar.toSnackBar(this));
  }

  double get iconSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 2.5);
      case DSDeviceResolution.desktop:
        return space(factor: 2);
    }
  }

  /// Standard responsive horizontal screen padding used across sections.
  /// mobile: space(3) · tablet: space(5) · desktop: 15 % of screen width
  EdgeInsets get screenHorizontalPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return EdgeInsets.symmetric(horizontal: space(factor: 3));
      case DSDeviceResolution.tablet:
        return EdgeInsets.symmetric(horizontal: space(factor: 5));
      case DSDeviceResolution.desktop:
        return EdgeInsets.symmetric(horizontal: width * 0.15);
    }
  }

  bool get isAndroid {
    final platform = Theme.of(this).platform;
    return platform == TargetPlatform.android;
  }

  bool get isiOS {
    final platform = Theme.of(this).platform;
    return platform == TargetPlatform.iOS;
  }
}

const _firstPrintableAsciiChar = 32;
const _lastPrintableAsciiChar = 255;
final _stringWithAllAsciiCharCodes = String.fromCharCodes(
  List.generate(
    _lastPrintableAsciiChar - _firstPrintableAsciiChar,
    (index) => _firstPrintableAsciiChar + index,
  ),
);

const _maximumSingleLineHeights = 64;

/// Single-line text heights by text style and text scaler.
///
/// The height of one line does not depend on its text, so it is measured once
/// per style and scaler, and measured again after the system fonts change.
final _singleLineHeights = <(TextStyle, TextScaler), double>{};

bool _isListeningToSystemFonts = false;

double _singleLineHeightOf(TextStyle textStyle, TextScaler textScaler) {
  if (!_isListeningToSystemFonts) {
    PaintingBinding.instance.systemFonts.addListener(_singleLineHeights.clear);
    _isListeningToSystemFonts = true;
  }
  final cacheKey = (textStyle, textScaler);
  final cachedHeight = _singleLineHeights[cacheKey];
  if (cachedHeight != null) return cachedHeight;

  final textPainter = TextPainter(
    text: TextSpan(text: _stringWithAllAsciiCharCodes, style: textStyle),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    strutStyle: StrutStyle.fromTextStyle(textStyle),
    textScaler: textScaler,
  )..layout();
  final lineHeight = textPainter.height;
  textPainter.dispose();
  if (_singleLineHeights.length >= _maximumSingleLineHeights) {
    _singleLineHeights.clear();
  }
  return _singleLineHeights[cacheKey] = lineHeight;
}
