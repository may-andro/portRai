import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';

part 'hero_widget.dart';

part 'service_detail_widget.dart';

part 'section_widget.dart';

part 'faq_widget.dart';

part 'motion_widget.dart';

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
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroWidget(service: service),
              _ServiceDetailWidget(service: service),
              BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  return switch (state) {
                    LoadedState(:final profile) => FooterWidget(
                      profile: profile,
                    ),
                    LoadingState() => const SizedBox.shrink(),
                  };
                },
              ),
            ],
          ),
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
