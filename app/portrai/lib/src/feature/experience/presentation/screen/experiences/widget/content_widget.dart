import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ExperiencesBloc, ExperiencesState>(
      impressionPrefix: 'experiences',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState(:final experiences, :final profile) => ScreenLoadedContent(
          _SuccessWidget(experiences: experiences, profile: profile),
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget({required this.experiences, this.profile});

  final List<ExperienceEntity> experiences;
  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        PageAppBarWidget(title: context.localizations.experiencesTitle),
        SliverPadding(
          padding: context.screenHorizontalPadding.copyWith(
            top: context.space(factor: 3),
            bottom: context.space(factor: 3),
          ),
          sliver: SliverToBoxAdapter(
            child: ExperienceListWidget(
              experiences: experiences,
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
