import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/design_system/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

part 'ambience_widget.dart';
part 'apply_panel_widget.dart';
part 'deck_widget.dart';
part 'gallery_widget.dart';
part 'month_dial_widget.dart';
part 'steady_text_widget.dart';
part 'theme_card_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<
      DesignSystemGalleryBloc,
      DesignSystemGalleryState
    >(
      buildWhen: (previous, current) => previous != current,
      contentOf: (state) => switch (state) {
        DesignSystemGalleryLoadingState() => const ScreenLoadingContent(),
        final DesignSystemGalleryLoadedState state =>
          ScreenLoadedContent.fullScreen(_GalleryWidget(state: state)),
      },
    );
  }
}
