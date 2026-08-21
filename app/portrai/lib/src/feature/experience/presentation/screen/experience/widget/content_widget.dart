import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/section_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
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
    return BlocBuilder<ExperienceBloc, ExperienceState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          final LoadingState _ => const _LoadingWidget(),
          final LoadedState state => _SuccessWidget(
            experience: state.experience,
          ),
          final ErrorState state => _ErrorWidget(
            message: FailureTranslator.translate(context, state.failure),
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
      impressionId: 'experience_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.loading()),
      child: DSLoadingWidget(
        size: max(context.shortestSide * 0.1, context.space(factor: 2)),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'experience_error_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: DSErrorCardWidget(message: message),
        ),
      ),
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
      TechnologiesSectionWidget(experience: widget.experience),
      AchievementsSectionWidget(experience: widget.experience),
      ResponsibilitiesSectionWidget(experience: widget.experience),
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
    return TrackingImpressionDetectorWidget(
      impressionId: 'experience_success_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
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
