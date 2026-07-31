import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'DSTextStyle', type: DSTextStyle)
Widget build(BuildContext context) {
  return ListView(
    children: [
      _ItemWidget('Display Large', context.typography.displayLarge.textStyle),
      _ItemWidget('Display Medium', context.typography.displayMedium.textStyle),
      _ItemWidget('Display Small', context.typography.displaySmall.textStyle),
      _ItemWidget(
        'Emphasized Display Large',
        context.typography.emphasizedDisplayLarge.textStyle,
      ),
      _ItemWidget(
        'Emphasized Display Medium',
        context.typography.emphasizedDisplayMedium.textStyle,
      ),
      _ItemWidget(
        'Emphasized Display Small',
        context.typography.emphasizedDisplaySmall.textStyle,
      ),
      _ItemWidget('Headline Large', context.typography.headlineLarge.textStyle),
      _ItemWidget(
        'Headline Medium',
        context.typography.headlineMedium.textStyle,
      ),
      _ItemWidget('Headline Small', context.typography.headlineSmall.textStyle),
      _ItemWidget(
        'Emphasized Headline Large',
        context.typography.emphasizedHeadlineLarge.textStyle,
      ),
      _ItemWidget(
        'Emphasized Headline Medium',
        context.typography.emphasizedHeadlineMedium.textStyle,
      ),
      _ItemWidget(
        'Emphasized Headline Small',
        context.typography.emphasizedHeadlineSmall.textStyle,
      ),
      _ItemWidget('Title Large', context.typography.titleLarge.textStyle),
      _ItemWidget('Title Medium', context.typography.titleMedium.textStyle),
      _ItemWidget('Title Small', context.typography.titleSmall.textStyle),
      _ItemWidget(
        'Emphasized Title Large',
        context.typography.emphasizedTitleLarge.textStyle,
      ),
      _ItemWidget(
        'Emphasized Title Medium',
        context.typography.emphasizedTitleMedium.textStyle,
      ),
      _ItemWidget(
        'Emphasized Title Small',
        context.typography.emphasizedTitleSmall.textStyle,
      ),
      _ItemWidget('Body Large', context.typography.bodyLarge.textStyle),
      _ItemWidget('Body Medium', context.typography.bodyMedium.textStyle),
      _ItemWidget('Body Small', context.typography.bodySmall.textStyle),
      _ItemWidget(
        'Emphasized Body Large',
        context.typography.emphasizedBodyLarge.textStyle,
      ),
      _ItemWidget(
        'Emphasized Body Medium',
        context.typography.emphasizedBodyMedium.textStyle,
      ),
      _ItemWidget(
        'Emphasized Body Small',
        context.typography.emphasizedBodySmall.textStyle,
      ),
      _ItemWidget('Label Large', context.typography.labelLarge.textStyle),
      _ItemWidget('Label Medium', context.typography.labelMedium.textStyle),
      _ItemWidget('Label Small', context.typography.labelSmall.textStyle),
      _ItemWidget(
        'Emphasized Label Large',
        context.typography.emphasizedLabelLarge.textStyle,
      ),
      _ItemWidget(
        'Emphasized Label Medium',
        context.typography.emphasizedLabelMedium.textStyle,
      ),
      _ItemWidget(
        'Emphasized Label Small',
        context.typography.emphasizedLabelSmall.textStyle,
      ),
    ],
  );
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget(this.title, this.textStyle);

  final String title;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: textStyle.copyWith(
          color: context.colorPalette.neutral.grey9.color,
        ),
      ),
      subtitle: Text(
        textStyle.description,
        style: const TextStyle(fontSize: 9),
      ),
    );
  }
}

extension _TextStyleExtension on TextStyle {
  String get fontSize => 'Font Size: ${this.fontSize}';

  String get letterSpacing => 'Letter Spacing: ${this.letterSpacing}';

  String get fontWeight => 'Font Weight: ${this.fontWeight}';

  String get description => '$fontSize, $letterSpacing, $fontWeight';
}
