import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:tracking/tracking.dart';

part 'mobile_tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'app_bar_widget.dart';

part 'tab_bar_widget.dart';

part 'header_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          final LoadingState _ => const _LoadingWidget(),
          final LoadedState state => _SuccessWidget(
            introSection: state.introSection,
            scrollableSections: state.scrollableSections,
          ),
        };
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'project_loading_content_view',
      onImpression: () {
        context.bloc.add(const LoadingContentViewVisibleEvent());
      },
      child: DSLoadingWidget(
        size: max(context.shortestSide * 0.1, context.space(factor: 2)),
      ),
    );
  }
}

class _SuccessWidget extends StatefulWidget {
  const _SuccessWidget({
    required this.introSection,
    required this.scrollableSections,
  });

  final ProjectSectionDTO introSection;
  final List<ScrollableProjectSectionDTO> scrollableSections;

  @override
  State<_SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<_SuccessWidget>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(
      length: widget.scrollableSections.length,
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
    return TrackingImpressionDetectorWidget(
      impressionId: 'project_success_content_view',
      onImpression: () {
        context.bloc.add(const SuccessContentViewVisibleEvent());
      },
      child: DSResponsiveContainerWidget(
        mobileBuilder: (context) {
          return _MobileTabletContentWidget(
            scrollController: _scrollController,
            tabController: _tabController,
          );
        },
        tabletBuilder: (context) {
          return _MobileTabletContentWidget(
            scrollController: _scrollController,
            tabController: _tabController,
          );
        },
        desktopBuilder: (context) => _DesktopContentWidget(
          scrollController: _scrollController,
          tabController: _tabController,
        ),
      ),
    );
  }

  void _onScroll() {
    final state = context.bloc.state;
    if (state is! LoadedState) return;

    final sections = state.scrollableSections;
    for (var i = 0; i < sections.length; i++) {
      final keyContext = sections[i].sectionKey.currentContext;
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

extension on BuildContext {
  double get horizontalPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return width * 0.15;
    }
  }
}
