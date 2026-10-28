import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/call_booking/call_booking.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/widget/_widget.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ServicesBloc, ServicesState>(
      impressionPrefix: 'services',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState(:final services) => ScreenLoadedContent.slivers([
          PageAppBarWidget(
            title: context.localizations.portfolioSectionServices,
            backgroundColor: context.colorPalette.surface.inverseSurface.color,
            titleColor: context.colorPalette.surface.onInverseSurface,
          ),
          SliverPadding(
            padding: context.screenHorizontalPadding.copyWith(
              top: context.space(factor: 3),
              bottom: context.space(factor: 3),
            ),
            sliver: SliverToBoxAdapter(
              child: ServiceListWidget(services: services, isVisible: true),
            ),
          ),
          const SliverToBoxAdapter(child: _BookCallSectionWidget()),
        ]),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

/// Offers a call to visitors who are unsure which service fits. Hidden while
/// booking is off.
class _BookCallSectionWidget extends StatelessWidget {
  const _BookCallSectionWidget();

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return BookCallEntryWidget(
      trackingLabel: 'services_book_call_button',
      builder: (context, onBookCall) => BookCallBandWidget(
        title: localizations.bookCallServiceTitle,
        description: localizations.bookCallServicesDescription,
        onBookCall: onBookCall,
      ),
    );
  }
}
