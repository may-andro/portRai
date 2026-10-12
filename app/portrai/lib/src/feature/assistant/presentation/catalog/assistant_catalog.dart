import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_map_locations.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/data_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/image_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/info_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/layout_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/link_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/map_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/project_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/story_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/text_items.dart';

/// The assistant's read-only A2UI vocabulary; no built-in catalog or functions.
/// [allowedUrls] enables `DSImage`; with [onOpenLink], `DSLinkButton` and
/// `DSContactCard` open only [allowedUrls] and [allowedContactLinks];
/// [allowedLocations] enables `DSMap`. Each is limited to the values given.
Catalog createAssistantCatalog({
  Set<String> allowedUrls = const {},
  Set<String> allowedContactLinks = const {},
  List<AssistantLocation> allowedLocations = const [],
  void Function(String url)? onOpenLink,
}) => Catalog([
  dsText,
  dsMetric,
  dsBulletList,
  dsCard,
  dsColumn,
  dsWrap,
  dsDivider,
  dsTag,
  dsInfoChip,
  dsLabeledInfoRow,
  dsExpandable,
  dsTimeline,
  dsSkillBars,
  dsQuote,
  dsStatGrid,
  dsCarousel,
  dsTabs,
  dsCallout,
  dsProgressRing,
  dsCodeBlock,
  dsComparison,
  dsEducationList,
  createDsProjectCard(allowedUrls),
  if (allowedUrls.isNotEmpty) createDsImage(allowedUrls),
  if ((allowedUrls.isNotEmpty || allowedContactLinks.isNotEmpty) &&
      onOpenLink != null) ...[
    createDsLinkButton(
      allowedLinks: {...allowedUrls, ...allowedContactLinks},
      onOpenLink: onOpenLink,
    ),
    createDsContactCard(
      allowedLinks: {...allowedUrls, ...allowedContactLinks},
      onOpenLink: onOpenLink,
    ),
  ],
  if (allowedLocations.isNotEmpty) createDsMap(allowedLocations),
], catalogId: 'dev.portrai.assistant');
