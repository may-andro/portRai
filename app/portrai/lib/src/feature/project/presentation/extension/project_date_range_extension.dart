import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

extension ProjectDateRangeExtension on ProjectEntity {
  String formattedDateRange(BuildContext context) {
    final format = DateFormat.yMMM(Localizations.localeOf(context).toString());
    final start = format.format(startDate).capitalize;
    final end = endDate != null
        ? format.format(endDate!).capitalize
        : context.localizations.present;
    return '$start - $end';
  }
}
