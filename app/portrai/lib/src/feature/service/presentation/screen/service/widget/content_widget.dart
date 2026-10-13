import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/service_detail_widget.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

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
          const SliverToBoxAdapter(child: PageHeaderWidget())
        else
          PageAppBarWidget(title: service.title),
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
        BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            return switch (state) {
              LoadedState(:final profile) => SliverToBoxAdapter(
                child: FooterWidget(profile: profile),
              ),
              LoadingState() => const SliverToBoxAdapter(),
            };
          },
        ),
      ],
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
