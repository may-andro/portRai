import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

const _maxTimelineEntries = 8;
const _maxSkills = 10;

List<JsonMap> _entries(Object? value, int max) => [
  if (value is List)
    for (final entry in value)
      if (entry is Map) JsonMap.from(entry),
].take(max).toList();

final dsTimeline = CatalogItem(
  name: 'DSTimeline',
  dataSchema: S.object(
    description:
        'A vertical timeline of roles, education or milestones, newest first.',
    properties: {
      'entries': S.list(
        description: 'At most $_maxTimelineEntries entries.',
        items: S.object(
          properties: {
            'period': S.string(description: 'For example 2021 - 2024.'),
            'title': S.string(description: 'Role or milestone.'),
            'subtitle': S.string(description: 'Company or place.'),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['entries'],
  ),
  widgetBuilder: (itemContext) {
    final entries = _entries(
      (itemContext.data as JsonMap)['entries'],
      _maxTimelineEntries,
    );
    return Builder(
      builder: (context) {
        final accent = context.colorPalette.brand.primary.color;
        final line = context.colorPalette.neutral.grey3.color;
        final dot = context.space(factor: 1.5);
        return Column(
          children: [
            for (final (index, entry) in entries.indexed)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: dot,
                      child: Column(
                        children: [
                          Container(
                            width: dot,
                            height: dot,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (index != entries.length - 1)
                            Expanded(child: Container(width: 2, color: line)),
                        ],
                      ),
                    ),
                    SizedBox(width: context.space(factor: 1.5)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index == entries.length - 1
                              ? 0
                              : context.space(factor: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry['period'] is String)
                              DSTextWidget(
                                '${entry['period']}',
                                style: context.typography.bodySmall,
                                color: context.colorPalette.neutral.grey7,
                              ),
                            DSTextWidget(
                              '${entry['title'] ?? ''}',
                              style: context.typography.emphasizedTitleMedium,
                              color: context.colorPalette.neutral.grey9,
                            ),
                            if (entry['subtitle'] is String)
                              DSTextWidget(
                                '${entry['subtitle']}',
                                style: context.typography.bodyMedium,
                                color: context.colorPalette.neutral.grey7,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  },
);

final dsSkillBars = CatalogItem(
  name: 'DSSkillBars',
  dataSchema: S.object(
    description:
        'Horizontal bars comparing skills or technologies, for example by '
        'years of experience. Values are relative, not percentages of skill.',
    properties: {
      'items': S.list(
        description: 'At most $_maxSkills items.',
        items: S.object(
          properties: {
            'label': S.string(description: 'Skill name.'),
            'value': S.number(description: 'Value, for example years.'),
            'display': S.string(description: 'Text shown, for example 5 yrs.'),
          },
          required: ['label', 'value'],
        ),
      ),
    },
    required: ['items'],
  ),
  widgetBuilder: (itemContext) {
    final items = _entries(
      (itemContext.data as JsonMap)['items'],
      _maxSkills,
    ).where((item) => item['value'] is num).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final maxValue = items
        .map((item) => (item['value']! as num).toDouble())
        .reduce(math.max);
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.25),
        children: [
          for (final item in items)
            _SkillBar(
              label: '${item['label'] ?? ''}',
              display: item['display'] as String?,
              fraction: maxValue <= 0
                  ? 0
                  : ((item['value']! as num).toDouble() / maxValue).clamp(
                      0.0,
                      1.0,
                    ),
            ),
        ],
      ),
    );
  },
);

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.label, required this.fraction, this.display});

  final String label;
  final String? display;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final height = context.space();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 0.5),
      children: [
        Row(
          children: [
            Expanded(
              child: DSTextWidget(
                label,
                style: context.typography.bodyMedium,
                color: context.colorPalette.neutral.grey9,
              ),
            ),
            if (display != null)
              DSTextWidget(
                display!,
                style: context.typography.bodySmall,
                color: context.colorPalette.neutral.grey7,
              ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Stack(
            children: [
              Container(
                height: height,
                color: context.colorPalette.neutral.grey3.color,
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: height,
                  color: context.colorPalette.brand.primary.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final dsQuote = CatalogItem(
  name: 'DSQuote',
  dataSchema: S.object(
    description:
        'A quotation, such as a testimonial, with its author. Copy the quote '
        'exactly from the portfolio information.',
    properties: {
      'text': S.string(description: 'The quote, without quotation marks.'),
      'author': S.string(description: 'Who said it.'),
      'role': S.string(description: 'Their role or company.'),
    },
    required: ['text'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final text = data['text'];
    if (text is! String || text.isEmpty) return const SizedBox.shrink();
    final author = data['author'] as String?;
    final role = data['role'] as String?;
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(),
        children: [
          DSQuoteTextWidget(
            text: text,
            maxLines: (text.length / 38).ceil().clamp(2, 10),
          ),
          if (author != null)
            DSTextWidget(
              role == null ? author : '$author, $role',
              style: context.typography.bodySmall,
              color: context.colorPalette.neutral.grey7,
            ),
        ],
      ),
    );
  },
);
