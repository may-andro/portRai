import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Spotlight Card', type: DSSpotlightCardWidget)
Widget buildSpotlightCard(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Mobile Development',
  );
  final showBackground = context.knobs.boolean(
    label: 'Show background art',
    initialValue: true,
  );

  return Center(
    child: SizedBox(
      width: 320,
      height: 180,
      child: DSSpotlightCardWidget(
        glowColor: context.colorPalette.brand.primary,
        fillColor: context.colorPalette.surface.onInverseSurface,
        onTap: () {},
        background: showBackground
            ? Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.phone_iphone,
                  size: 110,
                  color: context.colorPalette.brand.primary.color.withValues(
                    alpha: 0.25,
                  ),
                ),
              )
            : null,
        builder: (context, isHovering) => DSTextWidget(
          title,
          style: context.typography.titleLarge,
          color: context.colorPalette.neutral.grey9,
        ),
      ),
    ),
  );
}
