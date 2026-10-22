import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ExpertisesBloc, ExpertisesState>(
      impressionPrefix: 'expertises',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState(:final expertises, :final profile) => ScreenLoadedContent(
          _SuccessWidget(expertises: expertises, profile: profile),
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget({required this.expertises, this.profile});

  final List<ExpertiseEntity> expertises;
  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        PageAppBarWidget(title: context.localizations.expertisesTitle),
        SliverPadding(
          padding: context.screenHorizontalPadding.copyWith(
            top: context.space(factor: 3),
            bottom: context.space(factor: 3),
          ),
          sliver: SliverToBoxAdapter(
            child: ExpertiseListWidget(
              allExpertise: expertises,
              isVisible: true,
            ),
          ),
        ),
        if (profile case final ProfileEntity profile)
          SliverPadding(
            padding: EdgeInsets.only(top: context.space(factor: 3)),
            sliver: SliverToBoxAdapter(child: FooterWidget(profile: profile)),
          ),
      ],
    );
  }
}
