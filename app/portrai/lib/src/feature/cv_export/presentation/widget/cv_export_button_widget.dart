import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/cv_export_screen.dart';

/// Header action that opens the CV export screen.
class CvExportButtonWidget extends StatelessWidget {
  const CvExportButtonWidget({required this.size, super.key});

  final DSIconButtonSize size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.localizations.cvExportDownload,
      child: DSIconButtonWidget(
        Icons.description_outlined,
        size: size,
        iconColor: context.colorPalette.surface.onSurface,
        buttonColor: context.colorPalette.neutral.transparent,
        onPressed: () => CvExportScreen.navigate(context),
      ),
    );
  }
}
