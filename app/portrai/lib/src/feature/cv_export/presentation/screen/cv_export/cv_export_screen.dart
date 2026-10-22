import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/route/cv_export_module_route.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';

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
    return Scaffold(
      backgroundColor: context.colorPalette.background.color,
      body: BlocProvider(
        create: (_) {
          return appServiceLocator.get<CvExportBloc>()
            ..add(LoadCvExportEvent(labels, tailoringTarget: tailoringTarget));
        },
        child: BlocBuilder<CvExportBloc, CvExportState>(
          builder: (context, state) {
            switch (state) {
              case CvExportInitialState():
                return const _LoadingStateWidget();
              case CvExportLoadingState(:final isTailoring):
                return _LoadingStateWidget(isTailoring: isTailoring);
              case final CvExportLoadedState state:
                return ContentWidget(state: state);
              case CvExportErrorState(:final failure):
                return _MessageBodyWidget(
                  child: DSTextWidget(
                    FailureTranslator.translate(context, failure),
                    style: context.typography.bodyMedium,
                    color: context.colorPalette.surface.onSurface,
                    textAlign: TextAlign.center,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _LoadingStateWidget extends StatelessWidget {
  const _LoadingStateWidget({this.isTailoring = false});

  final bool isTailoring;

  @override
  Widget build(BuildContext context) {
    return _MessageBodyWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 2),
        children: [
          DSLoadingWidget(
            style: DSLoadingStyle.lottie,
            size: context.space(factor: 5),
          ),
          if (isTailoring)
            DSTextWidget(
              context.localizations.cvExportTailoring,
              style: context.typography.bodyMedium,
              color: context.colorPalette.neutral.grey7,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// A centered message under the page header.
class _MessageBodyWidget extends StatelessWidget {
  const _MessageBodyWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        PageAppBarWidget(title: context.localizations.cvExportTitle),
        SliverFillRemaining(hasScrollBody: false, child: Center(child: child)),
      ],
    );
  }
}
