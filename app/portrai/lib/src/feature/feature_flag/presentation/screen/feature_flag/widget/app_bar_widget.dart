import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({required this.height, super.key});

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagBloc, FeatureFlagState>(
      builder: (context, state) {
        return DSAppBarWidget(
          height: height,
          actions: state is! FeatureFlagLoadedState
              ? const []
              : [
                  DSIconButtonWidget(
                    state.viewMode == FeatureFlagViewMode.list
                        ? Icons.grid_view
                        : Icons.view_list,
                    iconColor: context.colorPalette.inverseSurface,
                    buttonColor: context.colorPalette.background,
                    onPressed: () {
                      context.bloc.add(const ToggleViewModeEvent());
                    },
                  ),
                  const DSHorizontalSpacerWidget(0.5),
                  DSIconButtonWidget(
                    Icons.refresh,
                    iconColor: context.colorPalette.inverseSurface,
                    buttonColor: context.colorPalette.background,
                    onPressed: () {
                      context.bloc.add(const ResetAllFeatureFlagsEvent());
                    },
                  ),
                  const DSHorizontalSpacerWidget(1),
                ],
        );
      },
    );
  }
}
