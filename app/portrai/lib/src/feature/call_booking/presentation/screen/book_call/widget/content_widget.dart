import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/call_booking/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/_bloc.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'form_widget.dart';
part 'hero_widget.dart';
part 'picker_widget.dart';
part 'sent_widget.dart';

/// Widest the form grows on phones and tablets.
const _contentMaxWidth = 560.0;

/// Widest the form grows beside the desktop panel.
const _splitBodyMaxWidth = 520.0;

/// Widest the confirmation card grows.
const _sentMaxWidth = 560.0;

/// What the page shows for each status. Sending keeps the form on screen.
enum _Page { loading, failed, booking, sent }

_Page _pageOf(BookCallStatus status) => switch (status) {
  BookCallStatus.loading => _Page.loading,
  BookCallStatus.loadFailed => _Page.failed,
  BookCallStatus.choosing || BookCallStatus.sending => _Page.booking,
  BookCallStatus.sent => _Page.sent,
};

/// A split screen on desktop, with the form beside the decorative panel.
/// Phones and tablets show a gradient header above the form.
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.topic});

  /// The topic filled in when the screen opens, or empty.
  final String topic;

  @override
  Widget build(BuildContext context) {
    final isSideBySide = context.isDesktop;
    final content = ScreenContentWidget<BookCallBloc, BookCallState>(
      // The sections rebuild themselves; the page changes only between
      // loading, failed, booking and sent.
      buildWhen: (previous, current) =>
          _pageOf(previous.status) != _pageOf(current.status),
      contentOf: (state) => switch (_pageOf(state.status)) {
        _Page.loading => const ScreenLoadingContent(),
        _Page.failed => ScreenErrorContent(
          state.loadFailure,
          onRetry: () => context.bloc.add(const CallSlotsRetryClickEvent()),
        ),
        _Page.booking => _loadedContent(
          isSideBySide: isSideBySide,
          isSent: false,
          body: _BookingWidget(topic: topic),
        ),
        _Page.sent => _loadedContent(
          isSideBySide: isSideBySide,
          isSent: true,
          body: const _SentWidget(),
        ),
      },
    );
    if (!isSideBySide) return content;

    final hasCloseButton =
        PageChrome.current == PageChrome.close &&
        Navigator.of(context).canPop();
    return Stack(
      children: [
        content,
        if (hasCloseButton)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(right: context.space()),
                // Sits on the dark panel.
                child: const PageCloseButtonWidget(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

ScreenLoadedContent _loadedContent({
  required bool isSideBySide,
  required bool isSent,
  required Widget body,
}) {
  if (isSideBySide) {
    return ScreenLoadedContent.slivers([
      SliverToBoxAdapter(
        child: _SplitWidget(body: body, isSent: isSent),
      ),
    ]);
  }
  return ScreenLoadedContent.slivers([
    const SliverToBoxAdapter(child: _HeroWidget()),
    SliverToBoxAdapter(
      child: _PageBodyWidget(
        maxWidth: isSent ? _sentMaxWidth : _contentMaxWidth,
        child: body,
      ),
    ),
  ]);
}

/// The desktop page: [body] on the left, with the logo on its top-left corner
/// as on every screen, and the panel on the right.
class _SplitWidget extends StatelessWidget {
  const _SplitWidget({required this.body, required this.isSent});

  /// The narrowest share of the width the panel takes.
  static const _minPanelWidthFactor = 0.34;

  final Widget body;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    final isHeaderShown = PageChrome.current == PageChrome.header;
    final headerHeight = isHeaderShown
        ? PageHeaderWidget.height(context)
        : MediaQuery.paddingOf(context).top;
    final sidePadding = context.screenHorizontalPadding.left;
    // The form side is the form plus the screen padding on both sides, so
    // the space left and right of the form matches; the panel takes the rest.
    final bodyWidth = min(
      _splitBodyMaxWidth + 2 * sidePadding,
      context.width * (1 - _minPanelWidthFactor),
    );
    final panelWidth = context.width - bodyWidth;
    // The logo sits left of the form unless the screen padding is narrower
    // than it, and only then does the form keep clear of it.
    final logoRight =
        PageHeaderWidget.horizontalPadding(context) + headerHeight;
    final verticalPadding = isHeaderShown && sidePadding < logoRight
        ? headerHeight
        : context.space(factor: 3);
    // The form sets the height, at least a screen tall; the panel stretches
    // beside it.
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: panelWidth,
          // A close button may sit on the panel's top-right corner.
          child: _VisualPanelWidget(topInset: headerHeight),
        ),
        Padding(
          padding: EdgeInsets.only(right: panelWidth),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: Padding(
              // The same space on opposite sides of the form.
              padding: EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isSent ? _sentMaxWidth : _splitBodyMaxWidth,
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        ),
        if (isHeaderShown)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PageHeaderWidget(),
          ),
      ],
    );
  }
}

class _PageBodyWidget extends StatelessWidget {
  const _PageBodyWidget({required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.screenHorizontalPadding.add(
        EdgeInsets.symmetric(vertical: context.space(factor: 4)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// The space between the rows of the form, from the day to the send button.
double _formRowSpacing(BuildContext context) => context.space(factor: 1.5);

/// One vertical form: the day and time first, then the visitor's details.
class _BookingWidget extends StatelessWidget {
  const _BookingWidget({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _formRowSpacing(context),
      children: [
        BlocBuilder<BookCallBloc, BookCallState>(
          buildWhen: (previous, current) =>
              previous.callSlots != current.callSlots ||
              previous.selectedDay != current.selectedDay ||
              previous.selectedSlot != current.selectedSlot ||
              previous.status != current.status,
          builder: (context, state) {
            final callSlots = state.callSlots;
            if (callSlots == null || callSlots.slots.isEmpty) {
              return const _NoSlotsWidget();
            }
            return _PickerWidget(
              slotsByDay: callSlots.slotsByLocalDay,
              selectedDay: state.selectedDay,
              selectedSlot: state.selectedSlot,
              isEnabled: state.status == BookCallStatus.choosing,
            );
          },
        ),
        _FormWidget(isCompact: context.isDesktop, topic: topic),
      ],
    );
  }
}
