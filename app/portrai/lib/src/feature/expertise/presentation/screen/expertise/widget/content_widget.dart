import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/lottie/_lottie.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/utility/app_lottie_assets.dart';
import 'package:portrai/src/widget/page_header_widget.dart';
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
    // The web always shows the logo header, whatever the window width.
    final useLogoHeader = kIsWeb || context.isDesktop;

    return TrackingImpressionDetectorWidget(
      impressionId: 'expertise_content_view',
      onImpression: () => context.bloc.add(const ContentVisibleEvent()),
      child: CustomScrollView(
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, overscroll: false),
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroWidget(
                  expertise: expertise,
                  showLogoHeader: useLogoHeader,
                ),
                _StatsBandWidget(expertise: expertise),
                _SkillsBandWidget(expertise: expertise),
                BlocBuilder<ExpertiseBloc, ExpertiseState>(
                  buildWhen: (previous, current) {
                    return previous.profile != current.profile;
                  },
                  builder: (context, state) {
                    final profile = state.profile;
                    if (profile == null) return const SizedBox.shrink();
                    return FooterWidget(profile: profile);
                  },
                ),
              ],
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
