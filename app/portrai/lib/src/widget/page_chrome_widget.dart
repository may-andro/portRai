import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

/// How a page lets the user navigate, decided by platform only:
/// the web (and desktop OSes) always show the logo header, Android shows a
/// close button, and iOS relies on the swipe-back gesture and shows neither.
enum PageChrome {
  header,
  close,
  none;

  static PageChrome get current {
    if (kIsWeb) return PageChrome.header;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PageChrome.close;
      case TargetPlatform.iOS:
        return PageChrome.none;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return PageChrome.header;
    }
  }
}

/// Close icon that pops the current route.
class PageCloseButtonWidget extends StatelessWidget {
  const PageCloseButtonWidget({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: Icon(Icons.close_rounded, color: color),
    );
  }
}

/// Wraps full-bleed page content (such as a hero) with the navigation chrome
/// for the current platform, see [PageChrome]. Without the logo header, the
/// close button and [actions] overlay the content, so they add no height.
class PageChromeWidget extends StatelessWidget {
  const PageChromeWidget({
    required this.child,
    required this.closeColor,
    this.actions = const [],
    super.key,
  });

  final Widget child;
  final Color closeColor;

  /// Shown at the end of the header on every platform, before the close
  /// button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final chrome = PageChrome.current;
    final hasCloseButton =
        chrome == PageChrome.close && Navigator.of(context).canPop();
    return Stack(
      children: [
        Column(
          children: [
            if (chrome == PageChrome.header)
              PageHeaderWidget(actions: actions)
            else
              SizedBox(height: MediaQuery.paddingOf(context).top),
            child,
          ],
        ),
        if (chrome != PageChrome.header &&
            (hasCloseButton || actions.isNotEmpty))
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: context.space()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...actions,
                      if (hasCloseButton)
                        PageCloseButtonWidget(color: closeColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
