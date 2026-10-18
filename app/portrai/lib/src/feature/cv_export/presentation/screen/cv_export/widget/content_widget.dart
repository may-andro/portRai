import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:printing/printing.dart';
import 'package:use_case/use_case.dart';

part 'accent_picker_widget.dart';
part 'controls_widget.dart';
part 'download_button_widget.dart';
part 'failure_widget.dart';
part 'preview_widget.dart';
part 'section_picker_widget.dart';
part 'section_title_widget.dart';
part 'template_picker_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({required this.state, super.key});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(context.space(factor: 2));

    if (context.isDesktop) {
      return Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.space(factor: 45),
              child: _ControlsWidget(state: state),
            ),
            SizedBox(width: context.space(factor: 3)),
            Expanded(child: _PreviewWidget(state: state)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: context.space(factor: 70),
            child: _PreviewWidget(state: state),
          ),
          SizedBox(height: context.space(factor: 2)),
          _ControlsWidget(state: state),
        ],
      ),
    );
  }
}
