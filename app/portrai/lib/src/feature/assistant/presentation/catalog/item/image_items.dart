import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Shows only [allowedUrls]; any other URL renders nothing, so the model cannot
/// make the app request arbitrary addresses.
CatalogItem createDsImage(Set<String> allowedUrls) => CatalogItem(
  name: 'DSImage',
  dataSchema: S.object(
    description:
        'An image from the portfolio. The url must be copied exactly from the '
        'portfolio information (for example a profile image, company logo or '
        'project image); never invent one.',
    properties: {
      'url': S.string(description: 'Exact image URL from the portfolio.'),
      'variant': S.string(
        description:
            'avatar for a person, logo for a company or technology, banner '
            'for a wide project or cover image.',
        enumValues: ['avatar', 'logo', 'banner'],
      ),
      'description': S.string(description: 'Short accessibility label.'),
    },
    required: ['url'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final url = data['url'];
    if (url is! String || !allowedUrls.contains(url)) {
      return const SizedBox.shrink();
    }
    return Builder(
      builder: (context) {
        final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
        final image = switch (data['variant']) {
          'avatar' => DSNetworkImageWidget(
            url: url,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            shape: BoxShape.circle,
          ),
          'logo' => DSNetworkImageWidget(
            url: url,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            borderRadius: radius,
          ),
          _ => AspectRatio(
            aspectRatio: 16 / 9,
            child: DSNetworkImageWidget(
              url: url,
              fit: BoxFit.cover,
              borderRadius: radius,
            ),
          ),
        };
        return Semantics(
          image: true,
          label: data['description'] as String?,
          child: image,
        );
      },
    );
  },
);
