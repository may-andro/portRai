import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/lottie/_lottie.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:tracking/tracking.dart';

part 'hero_widget.dart';

part 'section_widget.dart';

part 'skill_tile_widget.dart';

part 'skills_band_widget.dart';

part 'stats_band_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.expertise});

  final ExpertiseEntity expertise;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'expertise_content_view',
      onImpression: () => context.bloc.add(const ContentVisibleEvent()),
      child: ScreenContentWidget<ExpertiseBloc, ExpertiseState>(
        contentOf: (_) => ScreenLoadedContent.slivers([
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroWidget(expertise: expertise),
                _StatsBandWidget(expertise: expertise),
                _SkillsBandWidget(expertise: expertise),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
