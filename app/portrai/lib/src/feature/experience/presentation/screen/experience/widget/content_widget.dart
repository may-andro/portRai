import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/section_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'tab_bar_widget.dart';

class ContentWidget extends StatefulWidget {
  const ContentWidget({super.key});

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  _Sections? _sections;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sections?.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ExperienceBloc, ExperienceState>(
      impressionPrefix: 'experience',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState() => _loadedContentOf(state),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }

  ScreenLoadedContent _loadedContentOf(LoadedState state) {
    final experience = state.experience;
    final sections = _sectionsFor(experience);
    return ScreenLoadedContent.slivers(scrollController: _scrollController, [
      SliverToBoxAdapter(child: IntroSectionWidget(experience: experience)),
      SliverToBoxAdapter(child: KeyFactsSectionWidget(experience: experience)),
      SliverPersistentHeader(
        pinned: true,
        delegate: _PersistentTabBarDelegate(
          sections: sections.scrollableSections,
          tabController: sections.tabController,
          height: DSTabItemWidget.getHeight(context),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            ...sections.scrollableSections,
            if (state.newerExperience != null || state.olderExperience != null)
              AdjacentExperiencesSectionWidget(
                experience: experience,
                newerExperience: state.newerExperience,
                olderExperience: state.olderExperience,
              ),
          ],
        ),
      ),
    ]);
  }

  /// The sections of [experience] with their tab controller, kept across
  /// rebuilds so the section keys and the selected tab stay the same.
  _Sections _sectionsFor(ExperienceEntity experience) {
    final current = _sections;
    if (current != null && current.experience == experience) return current;

    final scrollableSections = <ScrollableSectionWidget>[
      OverviewSectionWidget(experience: experience),
      AchievementsSectionWidget(experience: experience),
      ResponsibilitiesSectionWidget(experience: experience),
      TechnologiesSectionWidget(experience: experience),
      if (experience.latitude != null && experience.longitude != null)
        LocationSectionWidget(experience: experience),
    ];
    final sections = _Sections(
      experience: experience,
      scrollableSections: scrollableSections,
      tabController: TabController(
        length: scrollableSections.length,
        vsync: this,
      ),
    );
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => current.tabController.dispose(),
      );
    }
    return _sections = sections;
  }

  void _onScroll() {
    final sections = _sections;
    if (sections == null) return;

    final scrollableSections = sections.scrollableSections;
    for (var i = 0; i < scrollableSections.length; i++) {
      final keyContext = scrollableSections[i].sectionKey.currentContext;
      if (keyContext case final BuildContext context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox case final RenderBox box) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position <= context.height / 2 &&
              position >= -box.size.height / 2) {
            if (sections.tabController.index != i) {
              sections.tabController.animateTo(i);
            }
            break;
          }
        }
      }
    }
  }
}

/// The scrollable sections of one experience and the tabs that follow them.
class _Sections {
  const _Sections({
    required this.experience,
    required this.scrollableSections,
    required this.tabController,
  });

  final ExperienceEntity experience;
  final List<ScrollableSectionWidget> scrollableSections;
  final TabController tabController;
}
