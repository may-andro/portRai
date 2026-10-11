import 'package:design_system/design_system.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The assistant's read-only A2UI vocabulary; no built-in catalog or functions.
Catalog createAssistantCatalog() =>
    Catalog([_text, _card], catalogId: 'dev.portrai.assistant');

final _text = CatalogItem(
  name: 'DSText',
  dataSchema: S.object(
    description: 'Plain text styled by the app design system.',
    properties: {'text': A2uiSchemas.stringReference()},
    required: ['text'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['text'],
      builder: (context, value) => DSTextWidget(
        value ?? '',
        style: context.typography.bodyMedium,
        color: context.colorPalette.neutral.grey9,
      ),
    );
  },
);

final _card = CatalogItem(
  name: 'DSCard',
  dataSchema: S.object(
    description: 'A design-system card containing one component by ID.',
    properties: {'child': A2uiSchemas.componentReference()},
    required: ['child'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    return DSCardWidget(
      child: itemContext.buildChild(data['child']! as String),
    );
  },
);
