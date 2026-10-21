import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

/// Openings posted this many days ago or less count as new.
const jobOpeningNewForDays = 3;

extension JobOpeningExtension on JobOpeningEntity {
  String formattedPublishedAt(BuildContext context) => DateFormat.yMMMd(
    Localizations.localeOf(context).toString(),
  ).format(publishedAt);

  /// Whole calendar days between the posting and [now], in local time:
  /// 0 for today, 1 for yesterday. Never negative.
  int daysSincePosted(DateTime now) {
    final posted = publishedAt.toLocal();
    final today = now.toLocal();
    final days = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(posted.year, posted.month, posted.day)).inDays;
    return days < 0 ? 0 : days;
  }

  bool isNew(DateTime now) => daysSincePosted(now) <= jobOpeningNewForDays;
}

extension JobTypeExtension on String {
  /// `full_time` as `Full time`.
  String get formattedJobType {
    final words = replaceAll(RegExp('[_-]+'), ' ').trim();
    return words.isEmpty
        ? words
        : '${words[0].toUpperCase()}${words.substring(1)}';
  }
}
