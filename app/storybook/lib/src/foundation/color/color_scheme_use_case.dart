import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'ColorScheme - Brand', type: BrandColorScheme)
Widget buildBrandColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.brand;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.primary.color, 'Primary'),
    _ColorAvatar(colorScheme.onPrimary.color, 'On Primary'),
    _ColorAvatar(colorScheme.primaryContainer.color, 'Primary Container'),
    _ColorAvatar(colorScheme.onPrimaryContainer.color, 'On Primary Container'),
    _ColorAvatar(colorScheme.primaryFixed.color, 'Primary Fixed'),
    _ColorAvatar(colorScheme.onPrimaryFixed.color, 'On Primary Fixed'),
    _ColorAvatar(colorScheme.primaryFixedDim.color, 'Primary Fixed Dim'),
    _ColorAvatar(
      colorScheme.onPrimaryFixedVariant.color,
      'On Primary Fixed Variant',
    ),
    _ColorAvatar(colorScheme.secondary.color, 'Secondary'),
    _ColorAvatar(colorScheme.onSecondary.color, 'On Secondary'),
    _ColorAvatar(colorScheme.secondaryContainer.color, 'Secondary Container'),
    _ColorAvatar(
      colorScheme.onSecondaryContainer.color,
      'On Secondary Container',
    ),
    _ColorAvatar(colorScheme.secondaryFixed.color, 'Secondary Fixed'),
    _ColorAvatar(colorScheme.onSecondaryFixed.color, 'On Secondary Fixed'),
    _ColorAvatar(colorScheme.secondaryFixedDim.color, 'Secondary Fixed Dim'),
    _ColorAvatar(
      colorScheme.onSecondaryFixedVariant.color,
      'On Secondary Fixed Variant',
    ),
    _ColorAvatar(colorScheme.tertiary.color, 'Tertiary'),
    _ColorAvatar(colorScheme.onTertiary.color, 'On Tertiary'),
    _ColorAvatar(colorScheme.tertiaryContainer.color, 'Tertiary Container'),
    _ColorAvatar(
      colorScheme.onTertiaryContainer.color,
      'On Tertiary Container',
    ),
    _ColorAvatar(colorScheme.tertiaryFixed.color, 'Tertiary Fixed'),
    _ColorAvatar(colorScheme.onTertiaryFixed.color, 'On Tertiary Fixed'),
    _ColorAvatar(colorScheme.tertiaryFixedDim.color, 'Tertiary Fixed Dim'),
    _ColorAvatar(
      colorScheme.onTertiaryFixedVariant.color,
      'On Tertiary Fixed Variant',
    ),
    _ColorAvatar(colorScheme.inversePrimary.color, 'Inverse Primary'),
  ]);
}

@UseCase(name: 'ColorScheme - Surface', type: SurfaceColorScheme)
Widget buildSurfaceColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.surface;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.surface.color, 'Surface'),
    _ColorAvatar(colorScheme.onSurface.color, 'On Surface'),
    _ColorAvatar(colorScheme.surfaceVariant.color, 'Surface Variant'),
    _ColorAvatar(colorScheme.onSurfaceVariant.color, 'On Surface Variant'),
    _ColorAvatar(colorScheme.surfaceDim.color, 'Surface Dim'),
    _ColorAvatar(colorScheme.surfaceBright.color, 'Surface Bright'),
    _ColorAvatar(colorScheme.surfaceContainerLowest.color, 'Container Lowest'),
    _ColorAvatar(colorScheme.surfaceContainerLow.color, 'Container Low'),
    _ColorAvatar(colorScheme.surfaceContainer.color, 'Container'),
    _ColorAvatar(colorScheme.surfaceContainerHigh.color, 'Container High'),
    _ColorAvatar(
      colorScheme.surfaceContainerHighest.color,
      'Container Highest',
    ),
    _ColorAvatar(colorScheme.inverseSurface.color, 'Inverse Surface'),
    _ColorAvatar(colorScheme.onInverseSurface.color, 'On Inverse Surface'),
    _ColorAvatar(colorScheme.inverseOnSurface.color, 'Inverse On Surface'),
  ]);
}

@UseCase(name: 'ColorScheme - Outline', type: OutlineColorScheme)
Widget buildOutlineColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.outline;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.outline.color, 'Outline'),
    _ColorAvatar(colorScheme.outlineVariant.color, 'Outline Variant'),
  ]);
}

@UseCase(name: 'ColorScheme - Utility', type: UtilityColorScheme)
Widget buildUtilityColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.utility;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.shadow.color, 'Shadow'),
    _ColorAvatar(colorScheme.scrim.color, 'Scrim'),
    _ColorAvatar(colorScheme.surfaceTint.color, 'Surface Tint'),
  ]);
}

@UseCase(name: 'ColorScheme - Neutral', type: NeutralColorScheme)
Widget buildNeutralColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.neutral;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.white.color, 'White'),
    _ColorAvatar(colorScheme.grey1.color, 'Grey 1'),
    _ColorAvatar(colorScheme.grey2.color, 'Grey 2'),
    _ColorAvatar(colorScheme.grey3.color, 'Grey 3'),
    _ColorAvatar(colorScheme.grey4.color, 'Grey 4'),
    _ColorAvatar(colorScheme.grey5.color, 'Grey 5'),
    _ColorAvatar(colorScheme.grey6.color, 'Grey 6'),
    _ColorAvatar(colorScheme.grey7.color, 'Grey 7'),
    _ColorAvatar(colorScheme.grey8.color, 'Grey 8'),
    _ColorAvatar(colorScheme.grey9.color, 'Grey 9'),
    _ColorAvatar(colorScheme.grey10.color, 'Grey 10'),
    _ColorAvatar(colorScheme.black.color, 'Black'),
    _ColorAvatar(colorScheme.transparent.color, 'Transparent'),
  ]);
}

@UseCase(name: 'ColorScheme - Semantic', type: SemanticColorScheme)
Widget buildSemanticColorScheme(BuildContext context) {
  final colorScheme = context.colorPalette.semantic;
  return _ColorAvatarBuilderWidget([
    _ColorAvatar(colorScheme.error.color, 'Error'),
    _ColorAvatar(colorScheme.onError.color, 'On Error'),
    _ColorAvatar(colorScheme.errorContainer.color, 'Error Container'),
    _ColorAvatar(colorScheme.onErrorContainer.color, 'On Error Container'),
    _ColorAvatar(colorScheme.warning.color, 'Warning'),
    _ColorAvatar(colorScheme.onWarning.color, 'On Warning'),
    _ColorAvatar(colorScheme.warningContainer.color, 'Warning Container'),
    _ColorAvatar(colorScheme.onWarningContainer.color, 'On Warning Container'),
    _ColorAvatar(colorScheme.success.color, 'Success'),
    _ColorAvatar(colorScheme.onSuccess.color, 'On Success'),
    _ColorAvatar(colorScheme.successContainer.color, 'Success Container'),
    _ColorAvatar(colorScheme.onSuccessContainer.color, 'On Success Container'),
    _ColorAvatar(colorScheme.info.color, 'Info'),
    _ColorAvatar(colorScheme.onInfo.color, 'On Info'),
    _ColorAvatar(colorScheme.infoContainer.color, 'Info Container'),
    _ColorAvatar(colorScheme.onInfoContainer.color, 'On Info Container'),
  ]);
}

class _ColorAvatar {
  _ColorAvatar(this.color, this.title);

  final Color color;
  final String title;
}

class _ColorAvatarBuilderWidget extends StatelessWidget {
  const _ColorAvatarBuilderWidget(this.colorAvatars);

  final List<_ColorAvatar> colorAvatars;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _ColorAvatarWidget(colorAvatars[index]);
      },
      shrinkWrap: true,
      itemCount: colorAvatars.length,
    );
  }
}

class _ColorAvatarWidget extends StatelessWidget {
  const _ColorAvatarWidget(this.colorAvatar);

  final _ColorAvatar colorAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.space(factor: 0.5)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: colorAvatar.color),
        title: Text(
          colorAvatar.title,
          style: context.typography.bodyLarge.textStyle.copyWith(
            color: context.colorPalette.neutral.grey9.color,
          ),
        ),
        subtitle: Text(
          colorAvatar.color.hex,
          style: context.typography.bodyMedium.textStyle.copyWith(
            color: context.colorPalette.neutral.grey7.color,
          ),
        ),
      ),
    );
  }
}

extension on Color {
  String get hex {
    final red = (r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final green = (g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final blue = (b * 255).toInt().toRadixString(16).padLeft(2, '0');
    final alpha = (a * 255).toInt().toRadixString(16).padLeft(2, '0');

    return '$alpha$red$green$blue';
  }
}
