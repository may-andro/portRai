import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/presentation/route/_route.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class FeatureFlagScreen extends StatelessWidget {
  const FeatureFlagScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(FeatureFlagModuleRoute.featureFlag);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return appServiceLocator.get<FeatureFlagBloc>()
          ..add(const LoadFeatureFlagEvent());
      },
      child: BlocBuilder<FeatureFlagBloc, FeatureFlagState>(
        builder: (context, state) {
          return RouteObserverWidget(
            onResume: () => context.bloc.add(const ScreenVisibleEvent()),
            child: Scaffold(
              appBar: DSAppBarWidget(
                height: DSAppBarWidget.getHeight(context),
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
              ),
              body: const Column(
                children: [
                  HeaderWidget(),
                  Expanded(child: ContentWidget()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
