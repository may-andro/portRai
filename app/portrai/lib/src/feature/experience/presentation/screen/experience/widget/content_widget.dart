import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/section_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'desktop_content_widget.dart';
part 'mobile_tablet_content_widget.dart';
part 'tab_bar_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ExperienceBloc, ExperienceState>(
      impressionPrefix: 'experience',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState(:final experience) => ScreenLoadedContent(
          _SuccessWidget(experience: experience),
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

class _SuccessWidget extends StatefulWidget {
  const _SuccessWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  State<_SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<_SuccessWidget>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TabController _tabController;
  late final List<ScrollableSectionWidget> _scrollableSections;

  @override
  void initState() {
    super.initState();
    // Create section widgets from experience entity
    _scrollableSections = [
      OverviewSectionWidget(experience: widget.experience),
      AchievementsSectionWidget(experience: widget.experience),
      ResponsibilitiesSectionWidget(experience: widget.experience),
      TechnologiesSectionWidget(experience: widget.experience),
      if (widget.experience.latitude != null &&
          widget.experience.longitude != null)
        LocationSectionWidget(experience: widget.experience),
    ];
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(
      length: _scrollableSections.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSResponsiveContainerWidget(
      mobileBuilder: (context) {
        return _MobileTabletContentWidget(
          experience: widget.experience,
          scrollableSections: _scrollableSections,
          scrollController: _scrollController,
          tabController: _tabController,
        );
      },
      tabletBuilder: (context) {
        return _MobileTabletContentWidget(
          experience: widget.experience,
          scrollableSections: _scrollableSections,
          scrollController: _scrollController,
          tabController: _tabController,
        );
      },
      desktopBuilder: (context) => _DesktopContentWidget(
        experience: widget.experience,
        scrollableSections: _scrollableSections,
        scrollController: _scrollController,
        tabController: _tabController,
      ),
    );
  }

  void _onScroll() {
    final state = context.bloc.state;
    if (state is! LoadedState) return;

    for (var i = 0; i < _scrollableSections.length; i++) {
      final keyContext = _scrollableSections[i].sectionKey.currentContext;
      if (keyContext case final BuildContext context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox case final RenderBox box) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position <= context.height / 2 &&
              position >= -box.size.height / 2) {
            if (_tabController.index != i) {
              _tabController.animateTo(i);
            }
            break;
          }
        }
      }
    }
  }
}

/// All scrollable sections followed by links to the neighbouring roles.
class _SectionListWidget extends StatelessWidget {
  const _SectionListWidget({required this.scrollableSections});

  final List<ScrollableSectionWidget> scrollableSections;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    return Column(
      children: [
        ...scrollableSections,
        if (state is LoadedState &&
            (state.newerExperience != null || state.olderExperience != null))
          AdjacentExperiencesSectionWidget(
            experience: state.experience,
            newerExperience: state.newerExperience,
            olderExperience: state.olderExperience,
          ),
      ],
    );
  }
}
