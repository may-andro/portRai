import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final dsText = CatalogItem(
  name: 'DSText',
  dataSchema: S.object(
    description: 'Plain text styled by the app design system. No markdown.',
    properties: {
      'text': A2uiSchemas.stringReference(),
      'variant': S.string(
        description:
            'heading for section titles, title for emphasized lines, body '
            '(default) for sentences, caption for secondary details.',
        enumValues: ['heading', 'title', 'body', 'caption'],
      ),
    },
    required: ['text'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['text'],
      builder: (context, value) {
        final (style, color) = switch (data['variant']) {
          'heading' => (
            context.typography.emphasizedTitleLarge,
            context.colorPalette.neutral.grey9,
          ),
          'title' => (
            context.typography.emphasizedTitleMedium,
            context.colorPalette.neutral.grey9,
          ),
          'caption' => (
            context.typography.bodySmall,
            context.colorPalette.neutral.grey7,
          ),
          _ => (
            context.typography.bodyMedium,
            context.colorPalette.neutral.grey9,
          ),
        };
        return DSTextWidget(value ?? '', style: style, color: color);
      },
    );
  },
);

final dsMetric = CatalogItem(
  name: 'DSMetric',
  dataSchema: S.object(
    description:
        'A highlighted number or short value with a label, for example '
        '"5+" and "years of Flutter experience".',
    properties: {
      'value': A2uiSchemas.stringReference(),
      'label': A2uiSchemas.stringReference(),
    },
    required: ['value', 'label'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['value'],
      builder: (context, value) => BoundString(
        dataContext: itemContext.dataContext,
        value: data['label'],
        builder: (context, label) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DSTextWidget(
              value ?? '',
              style: context.typography.emphasizedHeadlineMedium,
              color: context.colorPalette.brand.primary,
            ),
            DSTextWidget(
              label ?? '',
              style: context.typography.labelMedium,
              color: context.colorPalette.neutral.grey7,
            ),
          ],
        ),
      ),
    );
  },
);

final dsBulletList = CatalogItem(
  name: 'DSBulletList',
  dataSchema: S.object(
    description: 'A bulleted list of short plain-text items.',
    properties: {
      'items': S.list(
        description: 'Literal item texts; no markdown or bullet characters.',
        items: S.string(),
      ),
    },
    required: ['items'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final raw = data['items'];
    final items = [
      if (raw is List)
        for (final item in raw)
          if (item is String) item,
    ];
    return DSBulletPointListWidget(bulletPoints: items);
  },
);
