import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Opens only [allowedLinks] through [onOpenLink]; any other URL renders nothing,
/// so the model cannot send the user to an address it invented.
CatalogItem createDsLinkButton({
  required Set<String> allowedLinks,
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
    if (label is! String || url is! String || !allowedLinks.contains(url)) {
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

final _kindIcons = <String, IconData>{
  'email': Icons.mail_outline,
  'phone': Icons.phone_outlined,
  'website': Icons.language,
};

/// Like [createDsLinkButton], a group of contact buttons limited to
/// [allowedLinks]; entries outside them are skipped.
CatalogItem createDsContactCard({
  required Set<String> allowedLinks,
  required void Function(String url) onOpenLink,
}) => CatalogItem(
  name: 'DSContactCard',
  dataSchema: S.object(
    description:
        'Ways to get in touch: email, phone, LinkedIn, GitHub or a website. '
        'Each url is copied exactly from the portfolio; an email is '
        'mailto:<address> and a phone is tel:<number without spaces>.',
    properties: {
      'items': S.list(
        description: 'At most five contact methods.',
        items: S.object(
          properties: {
            'kind': S.string(
              description: 'email, phone or website.',
              enumValues: ['email', 'phone', 'website'],
            ),
            'label': S.string(description: 'Button text.'),
            'url': S.string(description: 'Exact link.'),
          },
          required: ['label', 'url'],
        ),
      ),
    },
    required: ['items'],
  ),
  widgetBuilder: (itemContext) {
    final items = [
      if ((itemContext.data as JsonMap)['items'] case final List<Object?> list)
        for (final item in list.take(5))
          if (item is Map &&
              item['label'] is String &&
              item['url'] is String &&
              allowedLinks.contains(item['url']))
            (
              kind: item['kind'],
              label: item['label'] as String,
              url: item['url'] as String,
            ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Builder(
      builder: (context) => Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: [
          for (final item in items)
            DSButtonWidget(
              label: item.label,
              icon: _kindIcons[item.kind] ?? Icons.open_in_new,
              variant: DSButtonVariant.secondary,
              size: DSButtonSize.small,
              onPressed: () => onOpenLink(item.url),
            ),
        ],
      ),
    );
  },
);
