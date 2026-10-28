import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/header/header_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

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
    return BlocListener<PortfolioBloc, PortfolioState>(
      listenWhen: (previous, current) {
        // Listen when tab index changes AND navigation is from drawer/header (not scroll)
        if (previous is LoadedState && current is LoadedState) {
          final indexChanged =
              previous.selectedSectionIndex != current.selectedSectionIndex;
          final isFromUserClick =
              current.lastNavigationSource == NavigationSource.drawer ||
              current.lastNavigationSource == NavigationSource.header;
          return indexChanged && isFromUserClick;
        }
        return false;
      },
      listener: (context, state) {
        if (state is LoadedState) {
          _scrollToSection(state.selectedSectionIndex);
        }
      },
      child: PrimaryScrollController(
        controller: _scrollController,
        child: ScreenContentWidget<PortfolioBloc, PortfolioState>(
          impressionPrefix: 'portfolio',
          contentOf: (state) => switch (state) {
            LoadingState() => const ScreenLoadingContent(),
            ErrorState(:final failure) => ScreenErrorContent(failure),
            LoadedState(
              :final portfolio,
              :final userRole,
              :final isScheduleAppointmentAvailable,
            ) =>
              _loadedContent(
                _sectionsFor(
                  portfolio,
                  userRole,
                  isScheduleAppointmentAvailable,
                ),
              ),
          },
          onContentVisible: (content) =>
              context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
        ),
      ),
    );
  }

  ScreenLoadedContent _loadedContent(_Sections sections) {
    return ScreenLoadedContent.slivers([
      HeaderWidget(
        sections: sections.widgets,
        tabController: sections.tabController,
      ),
      ...sections.widgets.map((section) => SliverToBoxAdapter(child: section)),
    ], scrollController: _scrollController);
  }

  /// Keeps the sections and their tab controller while the portfolio, role
  /// and appointment scheduling stay the same.
  _Sections _sectionsFor(
    PortfolioEntity portfolio,
    UserRole? userRole,
    bool isScheduleAppointmentAvailable,
  ) {
    final current = _sections;
    if (current != null &&
        current.portfolio == portfolio &&
        current.userRole == userRole &&
        current.isScheduleAppointmentAvailable ==
            isScheduleAppointmentAvailable) {
      return current;
    }
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => current.tabController.dispose(),
      );
    }
    final widgets = portfolio.sectionsFor(
      userRole,
      isScheduleAppointmentAvailable: isScheduleAppointmentAvailable,
    );
    return _sections = _Sections(
      portfolio: portfolio,
      userRole: userRole,
      isScheduleAppointmentAvailable: isScheduleAppointmentAvailable,
      widgets: widgets,
      tabController: TabController(length: widgets.length, vsync: this),
    );
  }

  void _scrollToSection(int index) {
    final sections = _sections?.widgets;
    if (sections == null || index < 0 || index >= sections.length) return;

    final keyContext = sections[index].sectionKey.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    final sections = _sections;
    if (sections == null) return;
    for (var i = 0; i < sections.widgets.length; i++) {
      final section = sections.widgets[i];
      final keyContext = section.sectionKey.currentContext;
      if (keyContext case final BuildContext context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox case final RenderBox box) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position <= context.height / 2 &&
              position >= -box.size.height / 2) {
            if (sections.tabController.index != i) {
              sections.tabController.animateTo(i);
              this.context.bloc.add(
                SectionNavigationEvent(
                  sectionIndex: i,
                  sectionId: section.trackingId,
                  source: NavigationSource.scroll,
                ),
              );
            }
            break;
          }
        }
      }
    }
  }
}

/// The scrollable sections of a loaded portfolio and the tabs that follow them.
class _Sections {
  const _Sections({
    required this.portfolio,
    required this.userRole,
    required this.isScheduleAppointmentAvailable,
    required this.widgets,
    required this.tabController,
  });

  final PortfolioEntity portfolio;
  final UserRole? userRole;
  final bool isScheduleAppointmentAvailable;
  final List<SectionWidget> widgets;
  final TabController tabController;
}
