import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';

part 'apply_band_widget.dart';
part 'hero_widget.dart';
part 'reasons_widget.dart';
part 'section_widget.dart';
part 'skills_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningBloc, JobOpeningState>(
      builder: (context, state) {
        return CustomScrollView(
          scrollBehavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          physics: const BouncingScrollPhysics(),
          slivers: switch (state.status) {
            JobOpeningStatus.loaded => [
              SliverToBoxAdapter(
                child: _DetailsWidget(jobOpening: state.jobOpening!),
              ),
            ],
            JobOpeningStatus.loading => [
              PageAppBarWidget(title: context.localizations.jobOpeningTitle),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: DSLoadingWidget(size: context.space(factor: 6)),
                ),
              ),
            ],
            JobOpeningStatus.failed => [
              PageAppBarWidget(title: context.localizations.jobOpeningTitle),
              SliverToBoxAdapter(
                child: JobOpeningPageColumnWidget(
                  verticalPadding: context.space(factor: 4),
                  child: DSErrorCardWidget(
                    message: state.loadFailure == null
                        ? null
                        : FailureTranslator.translate(
                            context,
                            state.loadFailure!,
                          ),
                    onRetryClicked: () =>
                        context.bloc.add(const JobOpeningRetryClickEvent()),
                  ),
                ),
              ),
            ],
          },
        );
      },
    );
  }
}

class _DetailsWidget extends StatelessWidget {
  const _DetailsWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

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
        _HeroWidget(jobOpening: jobOpening),
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
