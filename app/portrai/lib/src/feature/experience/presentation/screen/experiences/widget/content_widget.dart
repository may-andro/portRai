import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/experience_screen.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/widget/_widget.dart';
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
        LoadedState(:final experiences) => ScreenLoadedContent.slivers([
          PageAppBarWidget(title: context.localizations.experiencesTitle),
          SliverPadding(
            padding: context.screenHorizontalPadding.copyWith(
              top: context.space(factor: 3),
              bottom: context.space(factor: 6),
            ),
            sliver: SliverToBoxAdapter(
              child: ExperienceListWidget(
                experiences: experiences,
                isVisible: true,
                onClicked: (experience) {
                  context.bloc.add(ExperienceClickEvent(experience.id));
                  ExperienceScreen.navigate(context, id: experience.id);
                },
              ),
            ),
          ),
        ]),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}
