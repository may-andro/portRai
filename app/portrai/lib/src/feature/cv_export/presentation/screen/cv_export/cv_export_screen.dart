import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/cv_export/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/cv_export/presentation/route/cv_export_module_route.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';

class CvExportScreen extends StatelessWidget {
  const CvExportScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(CvExportModuleRoute.cvExport);
  }

  @override
  Widget build(BuildContext context) {
    // Read here: a bloc's create callback cannot listen to inherited widgets.
    final labels = context.cvLabels;
    return Scaffold(
      appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
      body: BlocProvider(
        create: (_) {
          return appServiceLocator.get<CvExportBloc>()
            ..add(LoadCvExportEvent(labels));
        },
        child: BlocBuilder<CvExportBloc, CvExportState>(
          builder: (context, state) {
            switch (state) {
              case CvExportInitialState():
              case CvExportLoadingState():
                return const _LoadingStateWidget();
              case final CvExportLoadedState state:
                return ContentWidget(state: state);
              case CvExportErrorState(:final failure):
                return Center(
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
  const _LoadingStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(child: DSLoadingWidget(size: context.space(factor: 5)));
  }
}
