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

final dsStatGrid = CatalogItem(
  name: 'DSStatGrid',
  dataSchema: S.object(
    description:
        'Shows two to four DSMetric components side by side, for example '
        'years of experience, projects and companies.',
    properties: {
      'children': S.list(
        description: 'DSMetric component IDs, at most four.',
        items: A2uiSchemas.componentReference(),
      ),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final children = buildCatalogChildren(itemContext, data['children']);
    return Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          for (final child in children.take(4)) Expanded(child: child),
        ],
      ),
    );
  },
);

final dsCarousel = CatalogItem(
  name: 'DSCarousel',
  dataSchema: S.object(
    description:
        'A horizontally scrolling row of cards, for several projects or '
        'testimonials.',
    properties: {
      'children': S.list(
        description: 'Component IDs, in display order, at most ten.',
        items: A2uiSchemas.componentReference(),
      ),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final children = buildCatalogChildren(itemContext, data['children']);
    return Builder(
      builder: (context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            for (final child in children.take(10))
              SizedBox(width: context.space(factor: 30), child: child),
          ],
        ),
      ),
    );
  },
);

final dsTabs = CatalogItem(
  name: 'DSTabs',
  dataSchema: S.object(
    description:
        'Switches between groups of content, for example frontend and '
        'backend skills. Each tab shows one child component.',
    properties: {
      'tabs': S.list(
        description: 'At most five tabs.',
        items: S.object(
          properties: {
            'title': S.string(description: 'Tab title.'),
            'child': A2uiSchemas.componentReference(),
          },
          required: ['title', 'child'],
        ),
      ),
    },
    required: ['tabs'],
  ),
  widgetBuilder: (itemContext) {
    final tabs = [
      if ((itemContext.data as JsonMap)['tabs'] case final List<Object?> list)
        for (final tab in list)
          if (tab is Map && tab['title'] is String && tab['child'] is String)
            (title: tab['title'] as String, child: tab['child'] as String),
    ].take(5).toList();
    if (tabs.isEmpty) return const SizedBox.shrink();
    return _TabsWidget(
      titles: [for (final tab in tabs) tab.title],
      childBuilders: [
        for (final tab in tabs) () => itemContext.buildChild(tab.child),
      ],
    );
  },
);

class _TabsWidget extends StatefulWidget {
  const _TabsWidget({required this.titles, required this.childBuilders});

  final List<String> titles;
  final List<Widget Function()> childBuilders;

  @override
  State<_TabsWidget> createState() => _TabsWidgetState();
}

class _TabsWidgetState extends State<_TabsWidget> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: context.space(factor: 1.25),
    children: [
      Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: [
          for (final (index, title) in widget.titles.indexed)
            DSButtonWidget(
              label: title,
              size: DSButtonSize.extraSmall,
              variant: index == _selected
                  ? DSButtonVariant.primary
                  : DSButtonVariant.secondary,
              onPressed: () => setState(() => _selected = index),
            ),
        ],
      ),
      widget.childBuilders[_selected](),
    ],
  );
}
