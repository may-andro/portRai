import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

/// Icons the model may reference by name; arbitrary code points are not allowed.
const assistantCatalogIcons = <String, IconData>{
  'work': Icons.work_outline,
  'code': Icons.code,
  'school': Icons.school_outlined,
  'location': Icons.location_on_outlined,
  'calendar': Icons.calendar_today_outlined,
  'email': Icons.mail_outline,
  'phone': Icons.phone_outlined,
  'link': Icons.link,
  'star': Icons.star_outline,
  'language': Icons.language,
  'business': Icons.business_outlined,
  'build': Icons.build_outlined,
  'person': Icons.person_outline,
  'trophy': Icons.emoji_events_outlined,
  'timer': Icons.timer_outlined,
};

IconData assistantCatalogIcon(Object? name) =>
    assistantCatalogIcons[name] ?? Icons.info_outline;

/// Builds every ID in [children]; non-string entries are ignored.
List<Widget> buildCatalogChildren(
  CatalogItemContext itemContext,
  Object? children,
) => [
  if (children is List)
    for (final id in children)
      if (id is String) itemContext.buildChild(id),
];
