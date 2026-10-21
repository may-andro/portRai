import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';

part 'details_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningBloc, JobOpeningState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            PageAppBarWidget(title: context.localizations.jobOpeningTitle),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.space(factor: 90),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.space(factor: 2)),
                    child: SafeArea(top: false, child: _body(context, state)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, JobOpeningState state) {
    return switch (state.status) {
      JobOpeningStatus.loading => Center(
        child: DSLoadingWidget(size: context.space(factor: 6)),
      ),
      JobOpeningStatus.failed => DSErrorCardWidget(
        message: state.loadFailure == null
            ? null
            : FailureTranslator.translate(context, state.loadFailure!),
        onRetryClicked: () =>
            context.bloc.add(const JobOpeningRetryClickEvent()),
      ),
      JobOpeningStatus.loaded => _DetailsWidget(jobOpening: state.jobOpening!),
    };
  }
}
