import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/cv_export/cv_export.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

/// Openings posted this many days ago or less count as new.
const jobOpeningNewForDays = 3;

/// Work that is not a regular position.
enum JobOpeningEngagement { contract, freelance }

final _freelancePattern = RegExp(r'\bfreelanc(e|er|ers|ing)\b');

// "Smart contract" names a blockchain skill, not the kind of engagement.
final _contractPattern = RegExp(r'(?<!smart )\bcontract(or|ors|ing)?\b');

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

  /// Freelance or contract work, read from the job types and the title, such
  /// as `Senior Android Engineer (Contract)`; null for a regular position.
  JobOpeningEngagement? get engagement {
    final text = [...jobTypes, title].join(' ').toLowerCase();
    if (_freelancePattern.hasMatch(text)) return JobOpeningEngagement.freelance;
    if (_contractPattern.hasMatch(text)) return JobOpeningEngagement.contract;
    return null;
  }

  /// The job to tailor a CV for.
  CvTailoringTargetEntity toCvTailoringTarget() => CvTailoringTargetEntity(
    title: title,
    company: company,
    description: description,
    skills: [...matchedSkills, ...missingSkills],
  );
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
