import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
part 'preview_widget.dart';
part 'section_widget.dart';
part 'section_picker_widget.dart';
part 'template_picker_widget.dart';

extension on BuildContext {
  /// Same page margins as the other screens.
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

class ContentWidget extends StatelessWidget {
  const ContentWidget({required this.state, super.key});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final controls = _ControlsWidget(state: state);
    final preview = _SectionWidget(
      title: context.localizations.cvExportPreviewSection,
      child: SizedBox(
        height: context.isDesktop
            ? MediaQuery.sizeOf(context).height * 0.75
            : context.space(factor: 70),
        child: _PreviewWidget(state: state),
      ),
    );

    return Stack(
      children: [
        CustomScrollView(
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
                child: context.isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: context.space(factor: 45),
                            child: controls,
                          ),
                          SizedBox(width: context.space(factor: 3)),
                          Expanded(child: preview),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [preview, controls],
                      ),
              ),
            ),
          ],
        ),
        Positioned(
          right: context.space(factor: 2),
          bottom: context.space(factor: 2),
          child: SafeArea(child: _DownloadButtonWidget(state: state)),
        ),
      ],
    );
  }
}
