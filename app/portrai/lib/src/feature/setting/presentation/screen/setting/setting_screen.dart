import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/setting/presentation/route/setting_module_route.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(SettingModuleRoute.setting);
  }

  @override
  Widget build(BuildContext context) {
    return RouteObserverWidget(
      onResume: () {
        if (isAssistantSupported) {
          context.read<AssistantBloc>().add(const AssistantInitializedEvent());
        }
      },
      child: Scaffold(
        appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
        body: BlocProvider(
          create: (_) {
            return appServiceLocator.get<SettingBloc>()
              ..add(const LoadSettingsEvent());
          },
          child: BlocBuilder<SettingBloc, SettingState>(
            builder: (context, state) {
              switch (state) {
                case SettingInitialState():
                case SettingLoadingState():
                  return const _LoadingStateWidget();
                case final SettingLoadedState state:
                  return ContentWidget(state: state);
                case SettingErrorState(:final message):
                  return Center(child: Text(message));
              }
            },
          ),
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
