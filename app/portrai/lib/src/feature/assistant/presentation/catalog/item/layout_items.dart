import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/catalog_item_helper.dart';

final dsCard = CatalogItem(
  name: 'DSCard',
  dataSchema: S.object(
    description:
        'A design-system card that groups related content. Use it for a '
        'distinct group, not around a simple one-line answer.',
    properties: {'child': A2uiSchemas.componentReference()},
    required: ['child'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return Builder(
      builder: (context) => DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 1.5)),
          child: itemContext.buildChild(data['child']! as String),
        ),
      ),
    );
  },
);

final dsColumn = CatalogItem(
  name: 'DSColumn',
  dataSchema: S.object(
    description:
        'Stacks child components vertically with design-system spacing.',
    properties: {
      'children': S.list(
        description: 'Component IDs, in display order.',
        items: A2uiSchemas.componentReference(),
      ),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.25),
        children: buildCatalogChildren(itemContext, data['children']),
      ),
    );
  },
);

final dsWrap = CatalogItem(
  name: 'DSWrap',
  dataSchema: S.object(
    description:
        'Lays out small children (DSTag, DSInfoChip) in a flowing row that '
        'wraps onto new lines.',
    properties: {
      'children': S.list(
        description: 'Component IDs, in display order.',
        items: A2uiSchemas.componentReference(),
      ),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return Builder(
      builder: (context) => Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: buildCatalogChildren(itemContext, data['children']),
      ),
    );
  },
);

final dsDivider = CatalogItem(
  name: 'DSDivider',
  dataSchema: S.object(
    description: 'A thin horizontal divider between groups of content.',
    properties: const {},
  ),
  widgetBuilder: (_) => Builder(
    builder: (context) => DSHorizontalDividerWidget(
      thickness: 1,
      color: context.colorPalette.neutral.grey3,
    ),
  ),
);
