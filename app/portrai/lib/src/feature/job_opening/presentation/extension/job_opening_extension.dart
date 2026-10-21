import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

extension JobOpeningExtension on JobOpeningEntity {
  String formattedPublishedAt(BuildContext context) => DateFormat.yMMMd(
    Localizations.localeOf(context).toString(),
  ).format(publishedAt);
}
