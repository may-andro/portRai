import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/metrics_widget.dart';
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
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ProjectBloc, ProjectState>(
      impressionPrefix: 'project',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        final LoadedState state => ScreenLoadedContent.slivers(
          _slivers(state),
          scrollController: _scrollController,
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }

  List<Widget> _slivers(LoadedState state) {
    final sections = state.scrollableSections;
    return [
      SliverToBoxAdapter(child: state.introSection.buildWidget(context)),
      SliverToBoxAdapter(child: MetricsWidget(project: state.project)),
      SliverPersistentHeader(
        pinned: true,
        delegate: _PersistentTabBarDelegate(
          sections: sections,
          tabController: _tabControllerFor(sections.length),
          height: DSTabItemWidget.getHeight(context),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            for (final section in sections) section.buildWidget(context),
          ],
        ),
      ),
    ];
  }

  /// The tab controller for [length] sections, replaced when the count
  /// changes.
  TabController _tabControllerFor(int length) {
    final current = _tabController;
    if (current != null && current.length == length) return current;
    current?.dispose();
    return _tabController = TabController(length: length, vsync: this);
  }

  void _onScroll() {
    final state = context.bloc.state;
    final tabController = _tabController;
    if (state is! LoadedState || tabController == null) return;

    final sections = state.scrollableSections;
    for (var i = 0; i < sections.length; i++) {
      final keyContext = sections[i].sectionKey.currentContext;
      if (keyContext case final BuildContext context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox case final RenderBox box) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position <= context.height / 2 &&
              position >= -box.size.height / 2) {
            if (tabController.index != i) {
              tabController.animateTo(i);
            }
            break;
          }
        }
      }
    }
  }
}
