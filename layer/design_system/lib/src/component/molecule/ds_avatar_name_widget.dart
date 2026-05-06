import 'dart:math';

import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/component/molecule/ds_network_image_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// A compact avatar + name/caption row.
///
/// Shows a circular [DSNetworkImageWidget] on the left followed by two lines
/// of text: a smaller [caption] (e.g. job title) above an [emphasizedBodyLarge]
/// [name].
///
/// Commonly used for testimonial authors, team members, reviewer cards, etc.
class DSAvatarNameWidget extends StatelessWidget {
  const DSAvatarNameWidget({
    super.key,
    required this.name,
    required this.caption,
    required this.imageUrl,
  });

  final String name;

  /// Subtitle shown above [name] — e.g. role, position, company.
  final String caption;
  final String imageUrl;

  static double getHeight(BuildContext context) {
    return max(_imageSize(context), _textsHeight(context));
  }

  static double _imageSize(BuildContext context) {
    switch (context.deviceResolution) {
      case DSDeviceResolution.mobile:
        return context.space(factor: 8);
      case DSDeviceResolution.tablet:
        return context.space(factor: 7);
      case DSDeviceResolution.desktop:
        return context.space(factor: 5);
    }
  }

  static double _textsHeight(BuildContext context) {
    return context.getTextHeight(context.typography.bodyMedium, 1) +
        context.getTextHeight(context.typography.emphasizedBodyLarge, 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = _imageSize(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 2),
      children: [
        DSNetworkImageWidget(
          url: imageUrl,
          width: size,
          height: size,
          shape: BoxShape.circle,
          fit: BoxFit.contain,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DSTextWidget(
                caption,
                color: context.colorPalette.neutral.grey7,
                style: context.typography.bodyMedium,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              DSTextWidget(
                name,
                color: context.colorPalette.neutral.grey9,
                style: context.typography.emphasizedBodyLarge,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


