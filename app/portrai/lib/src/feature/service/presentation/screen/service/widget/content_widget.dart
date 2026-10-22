import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

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
    return ScreenContentWidget<ServiceBloc, ServiceState>(
      contentOf: (_) => ScreenLoadedContent.slivers([
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSOffscreenPauseWidget(child: _HeroWidget(service: service)),
              _ServiceDetailWidget(service: service),
            ],
          ),
        ),
      ]),
    );
  }
}
