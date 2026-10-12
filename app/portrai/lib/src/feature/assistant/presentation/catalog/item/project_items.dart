import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The banner shows only [allowedUrls]; a URL outside them is skipped while the
/// rest of the card still renders.
CatalogItem createDsProjectCard(Set<String> allowedUrls) => CatalogItem(
  name: 'DSProjectCard',
  dataSchema: S.object(
    description:
        'A project summary card with an optional banner, description, '
        'technology tags and an optional action such as a DSLinkButton.',
    properties: {
      'title': S.string(description: 'Project name.'),
      'description': S.string(description: 'One or two sentences.'),
      'imageUrl': S.string(
        description: 'Banner URL copied exactly from the portfolio, if any.',
      ),
      'tags': S.list(
        description: 'Technologies, at most eight.',
        items: S.string(),
      ),
      'action': A2uiSchemas.componentReference(),
    },
    required: ['title'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final title = data['title'];
    if (title is! String) return const SizedBox.shrink();
    final imageUrl = data['imageUrl'];
    final description = data['description'];
    final tags = [
      if (data['tags'] case final List<Object?> list) ...list.take(8),
    ].map((tag) => '$tag').toList();
    final action = data['action'];
    return Builder(
      builder: (context) => DSCardWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl is String && allowedUrls.contains(imageUrl))
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DSNetworkImageWidget(url: imageUrl, fit: BoxFit.cover),
              ),
            Padding(
              padding: EdgeInsets.all(context.space(factor: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(),
                children: [
                  DSTextWidget(
                    title,
                    style: context.typography.emphasizedTitleMedium,
                    color: context.colorPalette.neutral.grey9,
                  ),
                  if (description is String)
                    DSTextWidget(
                      description,
                      style: context.typography.bodyMedium,
                      color: context.colorPalette.neutral.grey9,
                    ),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: context.space(),
                      runSpacing: context.space(),
                      children: [
                        for (final tag in tags) DSTagWidget(label: tag),
                      ],
                    ),
                  if (action is String) itemContext.buildChild(action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
