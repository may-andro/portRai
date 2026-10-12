import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

CatalogItem createDsSuggestionChips(
  void Function(String question) onAskQuestion,
) => CatalogItem(
  name: 'DSSuggestionChips',
  dataSchema: S.object(
    description:
        'Follow-up questions the user can tap to ask next. Place it last in '
        'the answer.',
    properties: {
      'suggestions': S.list(
        description:
            'Two to four short questions the portfolio information can '
            "answer, written from the visitor's point of view.",
        items: S.string(),
      ),
    },
    required: ['suggestions'],
  ),
  widgetBuilder: (itemContext) {
    final suggestions = [
      if ((itemContext.data as JsonMap)['suggestions']
          case final List<Object?> list)
        for (final item in list.take(4))
          if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Builder(
      builder: (context) => Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: [
          for (final suggestion in suggestions)
            DSButtonWidget(
              label: suggestion,
              variant: DSButtonVariant.secondary,
              size: DSButtonSize.extraSmall,
              onPressed: () => onAskQuestion(suggestion),
            ),
        ],
      ),
    );
  },
);
