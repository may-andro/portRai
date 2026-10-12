import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/info_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/layout_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/text_items.dart';

/// The assistant's read-only A2UI vocabulary; no built-in catalog or functions.
Catalog createAssistantCatalog() => Catalog([
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
], catalogId: 'dev.portrai.assistant');
