import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/route/cv_export_module_route.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class CvExportScreen extends StatelessWidget {
  const CvExportScreen({super.key, this.tailoringTarget});

  /// Opens the CV, tailored for [tailoringTarget] when given.
  static void navigate(
    BuildContext context, {
    CvTailoringTargetEntity? tailoringTarget,
  }) {
    context.pushScreen(CvExportModuleRoute.cvExport, extra: tailoringTarget);
  }

  /// The job to tailor the CV for, or null for the standard CV.
  final CvTailoringTargetEntity? tailoringTarget;

  @override
  Widget build(BuildContext context) {
    // Read here: a bloc's create callback cannot listen to inherited widgets.
    final labels = context.cvLabels;
    final loadEvent = LoadCvExportEvent(
      labels,
      tailoringTarget: tailoringTarget,
    );
    return Scaffold(
      backgroundColor: context.colorPalette.background.color,
      body: BlocProvider(
        create: (_) {
          return appServiceLocator.get<CvExportBloc>()..add(loadEvent);
        },
        child: Builder(
          builder: (context) =>
              ScreenContentWidget<CvExportBloc, CvExportState>(
                buildWhen: (previous, current) => previous != current,
                contentOf: (state) => switch (state) {
                  CvExportInitialState() => const ScreenLoadingContent(),
                  CvExportLoadingState(:final isTailoring) =>
                    ScreenLoadingContent(
                      message: isTailoring
                          ? context.localizations.cvExportTailoring
                          : null,
                    ),
                  CvExportErrorState(:final failure) => ScreenErrorContent(
                    failure,
                    onRetry: () => context.bloc.add(loadEvent),
                  ),
                  final CvExportLoadedState state => ScreenLoadedContent(
                    ContentWidget(state: state),
                  ),
                },
              ),
        ),
      ),
    );
  }
}
