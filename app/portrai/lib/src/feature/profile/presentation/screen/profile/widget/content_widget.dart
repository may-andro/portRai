import 'dart:math';
import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'about_band_widget.dart';
part 'background_band_widget.dart';
part 'body_widget.dart';
part 'contact_band_widget.dart';
part 'global_band_widget.dart';
part 'hero_widget.dart';
part 'motion_widget.dart';
part 'section_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<ProfileBloc, ProfileState>(
      impressionPrefix: 'profile',
      contentOf: (state) => switch (state) {
        LoadingState() => const ScreenLoadingContent(),
        ErrorState(:final failure) => ScreenErrorContent(failure),
        LoadedState(:final profile, :final workPlaces) =>
          ScreenLoadedContent.slivers([
            SliverToBoxAdapter(
              child: _BodyWidget(profile: profile, workPlaces: workPlaces),
            ),
          ]),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}
