import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

/// Top bar for scrolling pages, chosen by platform (see [PageChrome]): the
/// logo header on the web, a title bar with a close button on Android and a
/// plain title bar on iOS. Follows the theme background unless colors are
/// given.
class PageAppBarWidget extends StatelessWidget {
  const PageAppBarWidget({
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.actions = const [],
    super.key,
  });

  final String title;

  /// Shown at the end of the bar on every platform, before the close button.
  final List<Widget> actions;
  final Color? backgroundColor;
  final DSColor? titleColor;

  @override
  Widget build(BuildContext context) {
    final chrome = PageChrome.current;
    if (chrome == PageChrome.header) {
      return SliverToBoxAdapter(child: PageHeaderWidget(actions: actions));
    }

    final palette = context.colorPalette;
    final resolvedTitleColor = titleColor ?? palette.neutral.grey9;
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: backgroundColor ?? palette.background.color,
      surfaceTintColor: palette.neutral.transparent.color,
      foregroundColor: resolvedTitleColor.color,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: resolvedTitleColor,
        style: context.typography.emphasizedTitleMedium,
        maxLines: 1,
      ),
      actions: [
        ...actions,
        if (chrome == PageChrome.close && Navigator.of(context).canPop())
          Padding(
            padding: EdgeInsets.only(right: context.space()),
            child: PageCloseButtonWidget(color: resolvedTitleColor.color),
          ),
      ],
    );
  }
}

/// [PageAppBarWidget] for pages whose content fills the screen and scrolls
/// itself, such as a chat: the same header, but as a box above the content.
class PageTopBarWidget extends StatelessWidget {
  const PageTopBarWidget({
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Color? backgroundColor;
  final DSColor? titleColor;

  /// Shown at the end of the bar on every platform, before the close button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final chrome = PageChrome.current;
    if (chrome == PageChrome.header) {
      return PageHeaderWidget(actions: actions);
    }

    final palette = context.colorPalette;
    final resolvedTitleColor = titleColor ?? palette.neutral.grey9;
    return AppBar(
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: backgroundColor ?? palette.background.color,
      surfaceTintColor: palette.neutral.transparent.color,
      foregroundColor: resolvedTitleColor.color,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: resolvedTitleColor,
        style: context.typography.emphasizedTitleMedium,
        maxLines: 1,
      ),
      actions: [
        ...actions,
        if (chrome == PageChrome.close && Navigator.of(context).canPop())
          Padding(
            padding: EdgeInsets.only(right: context.space()),
            child: PageCloseButtonWidget(color: resolvedTitleColor.color),
          ),
      ],
    );
  }
}
