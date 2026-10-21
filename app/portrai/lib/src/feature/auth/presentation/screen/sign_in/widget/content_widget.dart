import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

part 'form_widget.dart';
part 'visual_panel_widget.dart';

const _formMaxWidth = 400.0;

/// A split screen: an animated visual panel beside the sign-in form on wide
/// screens, and a banner above the form on phones.
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final chrome = PageChrome.current;
    final isWide = !context.isMobile;
    final topInset = MediaQuery.paddingOf(context).top;

    final form = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 3),
          vertical: context.space(factor: isWide ? 6 : 3),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _formMaxWidth),
          child: const _FormWidget(),
        ),
      ),
    );

    return ColoredBox(
      color: palette.background.color,
      child: Stack(
        children: [
          CustomScrollView(
            scrollBehavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, overscroll: false),
            slivers: [
              if (isWide)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.all(context.space(factor: 2)),
                          child: const _VisualPanelWidget(isCompact: false),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (chrome == PageChrome.header)
                              const PageHeaderWidget()
                            else
                              SizedBox(height: topInset),
                            Expanded(child: form),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (chrome == PageChrome.header)
                        const PageHeaderWidget()
                      else
                        SizedBox(height: topInset),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.space(factor: 2),
                        ),
                        child: const _VisualPanelWidget(isCompact: true),
                      ),
                      form,
                    ],
                  ),
                ),
            ],
          ),
          if (chrome == PageChrome.close && Navigator.of(context).canPop())
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(right: context.space()),
                  child: PageCloseButtonWidget(
                    color: palette.neutral.grey10.color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
