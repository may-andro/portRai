import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/header/header_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:tracking/tracking.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          final LoadingState _ => const _LoadingWidget(),
          final ErrorState state => _ErrorWidget(
            errorMessage: FailureTranslator.translate(context, state.failure),
          ),
          final LoadedState state => _SuccessWidget(portfolio: state.portfolio),
        };
      },
    );
  }
}

class _SuccessWidget extends StatefulWidget {
  const _SuccessWidget({required this.portfolio});

  final PortfolioEntity portfolio;

  @override
  State<_SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<_SuccessWidget>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late final TabController _tabController;
  late final List<SectionWidget> _scrollableSections;

  @override
  void initState() {
    super.initState();
    _scrollableSections = widget.portfolio.scrollableSections;
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
      impressionId: 'home_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: BlocListener<PortfolioBloc, PortfolioState>(
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
          child: CustomScrollView(
            controller: _scrollController,
            scrollBehavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, overscroll: false),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              HeaderWidget(
                sections: _scrollableSections,
                tabController: _tabController,
              ),
              // Build each portfolio section as SliverToBoxAdapter widgets
              ..._scrollableSections.map((section) {
                return SliverToBoxAdapter(child: section);
              }),
              SliverToBoxAdapter(
                child: FooterWidget(profile: widget.portfolio.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    if (index < 0 || index >= _scrollableSections.length) return;

    final section = _scrollableSections[index];
    final keyContext = section.sectionKey.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    for (var i = 0; i < _scrollableSections.length; i++) {
      final section = _scrollableSections[i];
      final keyContext = section.sectionKey.currentContext;
      if (keyContext case final BuildContext context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox case final RenderBox box) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position <= context.height / 2 &&
              position >= -box.size.height / 2) {
            if (_tabController.index != i) {
              _tabController.animateTo(i);
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

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'portfolio_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.loading()),
      child: DSLoadingWidget(
        size: max(context.shortestSide * 0.1, context.space(factor: 2)),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'portfolio_failure_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.isDesktop
              ? context.width * 0.15
              : context.space(factor: 2),
        ),
        child: Center(child: DSErrorCardWidget(message: errorMessage)),
      ),
    );
  }
}
