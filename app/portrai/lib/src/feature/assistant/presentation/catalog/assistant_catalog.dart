import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/image_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/info_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/layout_items.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/item/text_items.dart';

/// The assistant's read-only A2UI vocabulary; no built-in catalog or functions.
/// [allowedImageUrls] enables `DSImage`, limited to exactly those URLs.
Catalog createAssistantCatalog({Set<String> allowedImageUrls = const {}}) =>
    Catalog([
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
      if (allowedImageUrls.isNotEmpty) createDsImage(allowedImageUrls),
    ], catalogId: 'dev.portrai.assistant');
