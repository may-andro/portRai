import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Opens only [allowedUrls] through [onOpenLink]; any other URL renders nothing,
/// so the model cannot send the user to an address it invented.
CatalogItem createDsLinkButton({
  required Set<String> allowedUrls,
  required void Function(String url) onOpenLink,
}) => CatalogItem(
  name: 'DSLinkButton',
  dataSchema: S.object(
    description:
        'A button that opens a link from the portfolio information, such as '
        'a project, company, social profile or article. The url must be '
        'copied exactly; never invent one.',
    properties: {
      'label': S.string(description: 'Button text.'),
      'url': S.string(description: 'Exact URL from the portfolio.'),
    },
    required: ['label', 'url'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final label = data['label'];
    final url = data['url'];
    if (label is! String || url is! String || !allowedUrls.contains(url)) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: DSButtonWidget(
        label: label,
        icon: Icons.open_in_new,
        variant: DSButtonVariant.secondary,
        size: DSButtonSize.small,
        onPressed: () => onOpenLink(url),
      ),
    );
  },
);
