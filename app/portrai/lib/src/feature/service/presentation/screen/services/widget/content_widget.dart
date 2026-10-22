import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
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
        ]),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}
