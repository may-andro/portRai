import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:printing/printing.dart';
import 'package:use_case/use_case.dart';
part 'accent_picker_widget.dart';
part 'controls_widget.dart';
part 'download_bar_widget.dart';
part 'failure_widget.dart';
part 'header_action_widget.dart';
part 'intro_widget.dart';
part 'option_card_widget.dart';
part 'preview_widget.dart';
part 'section_widget.dart';
part 'section_picker_widget.dart';
part 'template_picker_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({required this.state, super.key});

  final CvExportLoadedState state;

  static const double _maxContentWidth = 1200;

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

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              PageAppBarWidget(
                title: context.localizations.cvExportTitle,
                actions: [_HeaderActionWidget(state: state)],
              ),
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.space(factor: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _IntroWidget(),
                          if (context.isDesktop)
                            Row(
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
                          else ...[
                            preview,
                            controls,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _DownloadBarWidget(state: state),
      ],
    );
  }
}
