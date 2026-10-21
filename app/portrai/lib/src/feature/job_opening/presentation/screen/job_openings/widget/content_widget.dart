import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/job_opening_screen.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';

part 'job_opening_card_widget.dart';
part 'job_search_card_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningsBloc, JobOpeningsState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            PageAppBarWidget(title: context.localizations.jobOpeningsTitle),
            SliverToBoxAdapter(
              child: _ConstrainedWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DSTextWidget(
                      context.localizations.jobOpeningsDescription,
                      style: context.typography.bodyMedium,
                      color: context.colorPalette.neutral.grey7,
                    ),
                    const DSVerticalSpacerWidget(2),
                    if (state.isJobSearchEnabled case final isEnabled?)
                      _JobSearchCardWidget(
                        isEnabled: isEnabled,
                        isUpdating: state.isUpdatingJobSearch,
                      ),
                  ],
                ),
              ),
            ),
            ..._jobOpeningSlivers(context, state),
            SliverToBoxAdapter(
              child: _ConstrainedWidget(
                child: SafeArea(
                  top: false,
                  child: DSButtonWidget(
                    label: context.localizations.signOutButton,
                    variant: DSButtonVariant.text,
                    size: DSButtonSize.small,
                    isLoading: state.isSigningOut,
                    isDisabled: state.isSigningOut || state.isSignedOut,
                    onPressed: () =>
                        context.bloc.add(const SignOutClickEvent()),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _jobOpeningSlivers(
    BuildContext context,
    JobOpeningsState state,
  ) {
    switch (state.status) {
      case JobOpeningsStatus.loading:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.space(factor: 4)),
              child: Center(
                child: DSLoadingWidget(size: context.space(factor: 6)),
              ),
            ),
          ),
        ];
      case JobOpeningsStatus.failed:
        return [
          SliverToBoxAdapter(
            child: _ConstrainedWidget(
              child: DSErrorCardWidget(
                message: state.loadFailure == null
                    ? null
                    : FailureTranslator.translate(context, state.loadFailure!),
                onRetryClicked: () =>
                    context.bloc.add(const JobOpeningsRetryClickEvent()),
              ),
            ),
          ),
        ];
      case JobOpeningsStatus.loaded when state.jobOpenings.isEmpty:
        return [
          SliverToBoxAdapter(
            child: _ConstrainedWidget(
              child: DSTextWidget(
                context.localizations.jobOpeningsEmpty,
                style: context.typography.bodyLarge,
                color: context.colorPalette.neutral.grey7,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ];
      case JobOpeningsStatus.loaded:
        return [
          SliverList.builder(
            itemCount: state.jobOpenings.length,
            itemBuilder: (context, index) => _ConstrainedWidget(
              child: _JobOpeningCardWidget(
                jobOpening: state.jobOpenings[index],
              ),
            ),
          ),
        ];
    }
  }
}

/// Keeps the page readable on wide screens.
class _ConstrainedWidget extends StatelessWidget {
  const _ConstrainedWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.space(factor: 90)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 2),
            vertical: context.space(),
          ),
          child: child,
        ),
      ),
    );
  }
}
