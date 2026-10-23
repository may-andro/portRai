import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/src/feature/design_system/presentation/route/design_system_module_route.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/widget/_widget.dart';
import 'package:portrai/src/route/route.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

/// Shows every design system as a deck of cards. The screen takes on the look
/// of the card in front, and the chosen one is applied with a restart.
class DesignSystemGalleryScreen extends StatelessWidget {
  const DesignSystemGalleryScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(DesignSystemModuleRoute.designSystemGallery);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffoldWidget<
      DesignSystemGalleryBloc,
      DesignSystemGalleryState
    >(
      onCreate: (bloc) => bloc.add(const LoadDesignSystemGalleryEvent()),
      onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
      listenWhen: (previous, current) =>
          current is DesignSystemGalleryLoadedState && current.failure != null,
      listener: (context, state) {
        if (state case DesignSystemGalleryLoadedState(:final failure?)) {
          context.showSnackBar(
            snackBar: DSSnackBar(
              message: FailureTranslator.translate(context, failure),
              type: DSSnackBarType.error,
            ),
          );
        }
      },
      body: const ContentWidget(),
    );
  }
}
