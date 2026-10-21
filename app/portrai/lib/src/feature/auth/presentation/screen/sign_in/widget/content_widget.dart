import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

part 'form_widget.dart';
part 'visual_panel_widget.dart';

const _formMaxWidth = 400.0;

/// A split screen on desktop, with the visual panel beside the sign-in form.
/// Phones and tablets show the form first and the panel after it, as a
/// full-width band. The profile footer closes the page.
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final chrome = PageChrome.current;
    // Side by side only on desktop; phones and tablets put the form first.
    final isSideBySide = context.isDesktop;

    final form = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 3),
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
          CustomScrollView(
            scrollBehavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, overscroll: false),
            slivers: [
              if (isSideBySide)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(
                              flex: 5,
                              child: _VisualPanelWidget(isCompact: false),
                            ),
                            Expanded(flex: 4, child: form),
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
                      header,
                      form,
                      const _VisualPanelWidget(isCompact: true),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: BlocSelector<SignInBloc, SignInState, ProfileEntity?>(
                  selector: (state) => state.profile,
                  builder: (context, profile) => profile == null
                      ? SizedBox(height: MediaQuery.paddingOf(context).bottom)
                      : FooterWidget(profile: profile),
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
