import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/job_opening_screen.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';

part 'control_card_widget.dart';
part 'grid_widget.dart';
part 'hero_widget.dart';
part 'job_opening_card_widget.dart';
part 'status_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningsBloc, JobOpeningsState>(
      builder: (context, state) {
        return CustomScrollView(
          scrollBehavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HeroWidget(state: state)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.space(factor: 6)),
                child: JobOpeningPageColumnWidget(
                  child: _bodyFor(context, state),
                ),
              ),
            ),
            if (state.profile case final profile?)
              SliverToBoxAdapter(child: FooterWidget(profile: profile)),
          ],
        );
      },
    );
  }

  Widget _bodyFor(BuildContext context, JobOpeningsState state) {
    return switch (state.status) {
      JobOpeningsStatus.loading => const _LoadingWidget(),
      JobOpeningsStatus.failed => DSErrorCardWidget(
        message: state.loadFailure == null
            ? null
            : FailureTranslator.translate(context, state.loadFailure!),
        onRetryClicked: () =>
            context.bloc.add(const JobOpeningsRetryClickEvent()),
      ),
      JobOpeningsStatus.loaded when state.jobOpenings.isEmpty =>
        const _EmptyWidget(),
      JobOpeningsStatus.loaded => _GridWidget(jobOpenings: state.jobOpenings),
    };
  }
}
