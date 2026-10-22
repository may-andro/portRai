import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/setting/presentation/route/setting_module_route.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/_widget.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(SettingModuleRoute.setting);
  }

  @override
  Widget build(BuildContext context) {
    return LocalAssistantVisibilityWidget(
      child: ScreenScaffoldWidget<SettingBloc, SettingState>(
        onResume: (bloc) => bloc.add(const LoadSettingsEvent()),
        body: ScreenContentWidget<SettingBloc, SettingState>(
          buildWhen: (previous, current) => previous != current,
          contentOf: (state) => switch (state) {
            SettingInitialState() ||
            SettingLoadingState() => const ScreenLoadingContent(),
            SettingErrorState(:final failure) => ScreenErrorContent(failure),
            final SettingLoadedState state => ScreenLoadedContent.slivers([
              PageAppBarWidget(title: context.localizations.settingTitle),
              ContentWidget(state: state),
            ]),
          },
        ),
      ),
    );
  }
}
