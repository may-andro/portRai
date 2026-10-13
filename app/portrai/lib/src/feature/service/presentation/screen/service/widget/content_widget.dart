import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/service_detail_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (context.isDesktop)
          const SliverToBoxAdapter(child: _HeaderWidget())
        else
          _AppBarWidget(title: service.title),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: context.space(factor: 3),
            horizontal: context.horizontalPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: ServiceDetailWidget(service: service),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: context.colorPalette.background.color,
      surfaceTintColor: context.colorPalette.neutral.transparent.color,
      automaticallyImplyLeading: !kIsWeb,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: context.colorPalette.neutral.grey9,
        style: kIsWeb
            ? context.typography.emphasizedTitleLarge
            : context.typography.emphasizedTitleMedium,
        maxLines: 1,
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
      child: Row(
        children: [
          Flexible(
            child: Image.asset(
              DSImage.logoPath,
              package: 'design_system',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  double get horizontalPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 3);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return width * 0.15;
    }
  }
}
