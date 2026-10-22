import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/metrics_widget.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'body_widget.dart';
part 'tab_bar_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ProjectBloc, ProjectState>(
      impressionPrefix: 'project',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(
          style: DSLoadingStyle.lottie,
        ),
        final LoadedState state => ScreenLoadedContent(
          _SuccessWidget(
            introSection: state.introSection,
            scrollableSections: state.scrollableSections,
          ),
        ),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
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
  late TabController _tabController;
  bool _hasTabController = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final length = widget.scrollableSections.length;
    if (!_hasTabController || _tabController.length != length) {
      if (_hasTabController) _tabController.dispose();
      _tabController = TabController(length: length, vsync: this);
      _hasTabController = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BodyWidget(
      scrollController: _scrollController,
      tabController: _tabController,
    );
  }

  void _onScroll() {
    final state = context.bloc.state;
    if (state is! LoadedState) return;

    final sections = widget.scrollableSections;
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
