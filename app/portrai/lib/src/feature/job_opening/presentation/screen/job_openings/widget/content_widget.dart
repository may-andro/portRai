import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/job_opening_screen.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'grid_widget.dart';
part 'hero_widget.dart';
part 'job_opening_card_widget.dart';
part 'job_search_widget.dart';
part 'status_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<JobOpeningsBloc, JobOpeningsState>(
      // Each section rebuilds only for its own part of the state, so loading
      // the job search setting does not rebuild the list.
      buildWhen: (_, _) => false,
      contentOf: (_) => ScreenLoadedContent.slivers([
        BlocBuilder<JobOpeningsBloc, JobOpeningsState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.jobOpenings != current.jobOpenings,
          builder: (context, state) =>
              SliverToBoxAdapter(child: _HeroWidget(state: state)),
        ),
        BlocBuilder<JobOpeningsBloc, JobOpeningsState>(
          buildWhen: (previous, current) =>
              previous.isJobSearchEnabled != current.isJobSearchEnabled ||
              previous.isUpdatingJobSearch != current.isUpdatingJobSearch ||
              previous.isSigningOut != current.isSigningOut ||
              previous.isSignedOut != current.isSignedOut,
          builder: (context, state) => SliverToBoxAdapter(
            child: JobOpeningBandWidget(
              isAlternate: true,
              child: _JobSearchWidget(state: state),
            ),
          ),
        ),
        // A sliver, so only the cards in view are built.
        JobOpeningBandSliverWidget(
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.space(factor: 2.5)),
                  child: JobOpeningSectionTitleWidget(
                    title: context.localizations.jobOpeningsMatchesTitle,
                    icon: Icons.work_outline_rounded,
                  ),
                ),
              ),
              ScreenContentSliverWidget<JobOpeningsBloc, JobOpeningsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.jobOpenings != current.jobOpenings ||
                    previous.loadFailure != current.loadFailure,
                contentOf: (state) => switch (state.status) {
                  JobOpeningsStatus.loading => const ScreenLoadingContent(),
                  JobOpeningsStatus.failed => ScreenErrorContent(
                    state.loadFailure,
                    onRetry: () =>
                        context.bloc.add(const JobOpeningsRetryClickEvent()),
                  ),
                  JobOpeningsStatus.loaded when state.jobOpenings.isEmpty =>
                    const ScreenLoadedContent.slivers([
                      SliverToBoxAdapter(child: _EmptyWidget()),
                    ]),
                  JobOpeningsStatus.loaded => ScreenLoadedContent.slivers([
                    _GridWidget(jobOpenings: state.jobOpenings),
                  ]),
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
