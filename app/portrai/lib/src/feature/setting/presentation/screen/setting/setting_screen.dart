import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/setting/presentation/route/setting_module_route.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(SettingModuleRoute.setting);
  }

  @override
  Widget build(BuildContext context) {
    return LocalAssistantVisibilityWidget(
      child: Scaffold(
        appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
        body: BlocProvider(
          create: (_) {
            return appServiceLocator.get<SettingBloc>();
          },
          child: Builder(
            builder: (context) => RouteObserverWidget(
              onResume: () => context.bloc.add(const LoadSettingsEvent()),
              child: ScreenContentWidget<SettingBloc, SettingState>(
                buildWhen: (previous, current) => previous != current,
                contentOf: (state) => switch (state) {
                  SettingInitialState() ||
                  SettingLoadingState() => const ScreenLoadingContent(),
                  SettingErrorState(:final failure) => ScreenErrorContent(
                    failure,
                  ),
                  final SettingLoadedState state => ScreenLoadedContent(
                    ContentWidget(state: state),
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
