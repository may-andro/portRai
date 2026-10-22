import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';
import 'package:printing/printing.dart';
import 'package:use_case/use_case.dart';
part 'accent_picker_widget.dart';
part 'controls_widget.dart';
part 'download_button_widget.dart';
part 'failure_widget.dart';
part 'hero_widget.dart';
part 'option_card_widget.dart';
part 'photo_picker_widget.dart';
part 'preview_widget.dart';
part 'section_widget.dart';
part 'section_picker_widget.dart';
part 'tailoring_banner_widget.dart';
part 'template_picker_widget.dart';

extension on BuildContext {
  /// Same page margins as the other screens, scaled by the window width.
  double get horizontalPadding {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
        return space(factor: 3);
      case DSDeviceWidthResolution.s:
        return space(factor: 5);
      case DSDeviceWidthResolution.m:
        return width * 0.08;
      case DSDeviceWidthResolution.l:
      case DSDeviceWidthResolution.xl:
        return width * 0.15;
    }
  }
}

/// The loaded CV as a sliver: the hero, then the preview and its controls,
/// with room at the bottom for [DownloadButtonWidget].
class ContentWidget extends StatelessWidget {
  const ContentWidget({required this.state, super.key});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final controls = _ControlsWidget(state: state);
    final preview = _SectionWidget(
      title: context.localizations.cvExportPreviewSection,
      child: _PreviewWidget(state: state),
    );

    Widget stackedBody(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [preview, controls],
    );
    Widget sideBySideBody(BuildContext context) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: context.space(factor: 45), child: controls),
        SizedBox(width: context.space(factor: 3)),
        Expanded(child: preview),
      ],
    );

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: _HeroWidget()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.horizontalPadding,
            context.space(factor: 3),
            context.horizontalPadding,
            context.space(factor: 14),
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TailoringBannerWidget(state: state),
                DSResponsiveWidthContainerWidget(
                  xsBuilder: stackedBody,
                  sBuilder: stackedBody,
                  mBuilder: stackedBody,
                  lBuilder: sideBySideBody,
                  xlBuilder: sideBySideBody,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
