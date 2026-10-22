import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/cv_export/cv_export.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'apply_band_widget.dart';
part 'hero_widget.dart';
part 'insights_widget.dart';
part 'reasons_widget.dart';
part 'section_widget.dart';
part 'skills_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<JobOpeningBloc, JobOpeningState>(
      // Insights update the state many times while they generate; their own
      // section rebuilds for them, so the page rebuilds only for what it shows.
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.jobOpening != current.jobOpening ||
          previous.loadFailure != current.loadFailure ||
          previous.isTailoredCvAvailable != current.isTailoredCvAvailable ||
          (previous.insightsStatus == JobOpeningInsightsStatus.unavailable) !=
              (current.insightsStatus == JobOpeningInsightsStatus.unavailable),
      contentOf: (state) => switch (state.status) {
        JobOpeningStatus.loading => const ScreenLoadingContent(),
        JobOpeningStatus.failed => ScreenErrorContent(
          state.loadFailure,
          onRetry: () => context.bloc.add(const JobOpeningRetryClickEvent()),
        ),
        JobOpeningStatus.loaded => ScreenLoadedContent.slivers([
          SliverToBoxAdapter(
            child: _DetailsWidget(
              jobOpening: state.jobOpening!,
              hasInsights:
                  state.insightsStatus != JobOpeningInsightsStatus.unavailable,
              isTailoredCvAvailable: state.isTailoredCvAvailable,
            ),
          ),
        ]),
      },
    );
  }
}

class _DetailsWidget extends StatelessWidget {
  const _DetailsWidget({
    required this.jobOpening,
    required this.hasInsights,
    required this.isTailoredCvAvailable,
  });

  final JobOpeningEntity jobOpening;
  final bool hasInsights;
  final bool isTailoredCvAvailable;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final hasSkills =
        jobOpening.matchedSkills.isNotEmpty ||
        jobOpening.missingSkills.isNotEmpty;
    final sections = [
      if (jobOpening.reasons.isNotEmpty)
        (
          title: localizations.jobOpeningReasonsTitle,
          icon: Icons.insights_rounded,
          child: _ReasonsWidget(reasons: jobOpening.reasons),
        ),
      if (hasSkills)
        (
          title: localizations.jobOpeningSkillsTitle,
          icon: Icons.code_rounded,
          child: _SkillsWidget(jobOpening: jobOpening),
        ),
      if (hasInsights)
        (
          title: localizations.jobOpeningInsightsTitle,
          icon: Icons.auto_awesome_rounded,
          child: const _InsightsWidget(),
        ),
      (
        title: localizations.jobOpeningDescriptionTitle,
        icon: Icons.description_outlined,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.space(factor: 95)),
          child: DSTextWidget(
            jobOpening.description,
            style: context.typography.bodyLarge,
            color: context.colorPalette.neutral.grey9,
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroWidget(
          jobOpening: jobOpening,
          isTailoredCvAvailable: isTailoredCvAvailable,
        ),
        for (final (sectionIndex, section) in sections.indexed)
          _SectionWidget(
            title: section.title,
            icon: section.icon,
            isAlternate: sectionIndex.isEven,
            child: section.child,
          ),
        _ApplyBandWidget(jobOpening: jobOpening),
      ],
    );
  }
}
