import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';

/// "Posted 3 days ago" as a pill, highlighted while the opening is new.
class JobOpeningPostedWidget extends StatelessWidget {
  const JobOpeningPostedWidget({super.key, required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final now = DateTime.now();
    final isNew = jobOpening.isNew(now);
    final color = isNew ? palette.semantic.success : palette.neutral.grey8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.25),
        vertical: context.space(factor: 0.5),
      ),
      decoration: BoxDecoration(
        color: color.color.withAlpha(isNew ? 36 : 22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.color.withAlpha(isNew ? 110 : 60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.5),
        children: [
          Icon(
            isNew ? Icons.auto_awesome_rounded : Icons.schedule_rounded,
            size: 16,
            color: color.color,
          ),
          Flexible(
            child: DSTextWidget(
              context.localizations.jobOpeningPostedAgo(
                jobOpening.daysSincePosted(now),
              ),
              style: context.typography.emphasizedLabelLarge,
              color: color,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
