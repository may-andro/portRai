import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

part 'background_widget.dart';
part 'form_card_widget.dart';
part 'intro_widget.dart';

const _maxContentWidth = 1100.0;
const _formCardWidth = 440.0;

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final chrome = PageChrome.current;
    final isWide = !context.isMobile;

    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Stack(
            children: [
              const Positioned.fill(child: _BackgroundWidget()),
              Column(
                children: [
                  if (chrome == PageChrome.header)
                    const PageHeaderWidget()
                  else
                    SizedBox(height: MediaQuery.paddingOf(context).top),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.space(factor: isWide ? 6 : 3),
                          vertical: context.space(factor: isWide ? 6 : 3),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _maxContentWidth,
                          ),
                          child: isWide
                              ? Row(
                                  spacing: context.space(factor: 8),
                                  children: const [
                                    Expanded(child: _IntroWidget()),
                                    SizedBox(
                                      width: _formCardWidth,
                                      child: _FormCardWidget(),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: context.space(factor: 4),
                                  children: const [
                                    _IntroWidget(),
                                    _FormCardWidget(),
                                  ],
                                ),
                        ),
                      ),
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
        ),
      ],
    );
  }
}
