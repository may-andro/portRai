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
/// for the current platform, see [PageChrome]. The close button overlays the
/// content, so it adds no height.
class PageChromeWidget extends StatelessWidget {
  const PageChromeWidget({
    required this.child,
    required this.closeColor,
    super.key,
  });

  final Widget child;
  final Color closeColor;

  @override
  Widget build(BuildContext context) {
    final chrome = PageChrome.current;
    return Stack(
      children: [
        Column(
          children: [
            if (chrome == PageChrome.header)
              const PageHeaderWidget()
            else
              SizedBox(height: MediaQuery.paddingOf(context).top),
            child,
          ],
        ),
        if (chrome == PageChrome.close && Navigator.of(context).canPop())
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: context.space()),
                  child: PageCloseButtonWidget(color: closeColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
