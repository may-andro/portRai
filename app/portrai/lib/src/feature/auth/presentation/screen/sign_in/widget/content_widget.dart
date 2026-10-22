import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'form_widget.dart';
part 'visual_panel_widget.dart';

const _formMaxWidth = 400.0;

/// A split screen on desktop, with the full-height welcome panel beside the
/// sign-in form. Phones and tablets show the panel as a full-width band
/// above the form.
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final chrome = PageChrome.current;
    // Side by side only on desktop; phones and tablets stack the panel first.
    final isSideBySide = context.isDesktop;

    final form = Center(
      child: Padding(
        // Stacked, the form lines up with the logo; side by side it is
        // centred in its half of the page.
        padding: EdgeInsets.symmetric(
          horizontal: isSideBySide
              ? context.space(factor: 3)
              : PageHeaderWidget.horizontalPadding(context),
          vertical: context.space(factor: isSideBySide ? 6 : 3),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _formMaxWidth),
          child: const _FormWidget(),
        ),
      ),
    );
    // The logo sits top-left across the whole page, as on every screen.
    final header = chrome == PageChrome.header
        ? const PageHeaderWidget()
        : SizedBox(height: MediaQuery.paddingOf(context).top);

    return ColoredBox(
      color: palette.background.color,
      child: Stack(
        children: [
          ScreenContentWidget<SignInBloc, SignInState>(
            // The form rebuilds itself; the page never changes with the state.
            buildWhen: (_, _) => false,
            contentOf: (_) => ScreenLoadedContent.slivers([
              if (isSideBySide)
                // The panel runs the full height; the logo sits on its
                // top-left corner, where it is on every screen.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            flex: 5,
                            child: _VisualPanelWidget(isCompact: false),
                          ),
                          Expanded(flex: 4, child: form),
                        ],
                      ),
                      Positioned(top: 0, left: 0, right: 0, child: header),
                    ],
                  ),
                )
              else ...[
                SliverToBoxAdapter(child: header),
                const SliverToBoxAdapter(
                  child: _VisualPanelWidget(isCompact: true),
                ),
                SliverToBoxAdapter(child: form),
              ],
            ]),
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
