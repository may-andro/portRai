import 'package:design_system/design_system.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/catalog_item_helper.dart';

final _iconSchema = S.string(
  description: 'Icon name.',
  enumValues: assistantCatalogIcons.keys.toList(),
);

final dsTag = CatalogItem(
  name: 'DSTag',
  dataSchema: S.object(
    description: 'A small badge for a skill, technology or category.',
    properties: {'label': A2uiSchemas.stringReference()},
    required: ['label'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['label'],
      builder: (context, label) => DSTagWidget(label: label ?? ''),
    );
  },
);

final dsInfoChip = CatalogItem(
  name: 'DSInfoChip',
  dataSchema: S.object(
    description:
        'A compact icon and label pill for metadata such as a date, '
        'location or role.',
    properties: {'icon': _iconSchema, 'label': A2uiSchemas.stringReference()},
    required: ['label'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['label'],
      builder: (context, label) => DSInfoChipWidget(
        icon: assistantCatalogIcon(data['icon']),
        label: label ?? '',
      ),
    );
  },
);

final dsLabeledInfoRow = CatalogItem(
  name: 'DSLabeledInfoRow',
  dataSchema: S.object(
    description:
        'An icon with a small label above a value, for facts such as '
        'company, period or location.',
    properties: {
      'icon': _iconSchema,
      'label': A2uiSchemas.stringReference(),
      'value': A2uiSchemas.stringReference(),
    },
    required: ['label', 'value'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['label'],
      builder: (context, label) => BoundString(
        dataContext: itemContext.dataContext,
        value: data['value'],
        builder: (context, value) => DSLabeledInfoRowWidget(
          icon: assistantCatalogIcon(data['icon']),
          label: label ?? '',
          value: value ?? '',
        ),
      ),
    );
  },
);

final dsExpandable = CatalogItem(
  name: 'DSExpandable',
  dataSchema: S.object(
    description:
        'A card showing a title that expands to reveal one child component. '
        'Use it for optional detail so the answer stays short.',
    properties: {
      'title': A2uiSchemas.stringReference(),
      'child': A2uiSchemas.componentReference(),
    },
    required: ['title', 'child'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['title'],
      builder: (context, title) => DSExpandableCardWidget(
        headerContent: DSTextWidget(
          title ?? '',
          style: context.typography.emphasizedTitleMedium,
          color: context.colorPalette.neutral.grey9,
        ),
        expandedContent: itemContext.buildChild(data['child']! as String),
      ),
    );
  },
);
