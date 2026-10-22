import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/assistant_launcher_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LocalAssistantVisibilityWidget(
      child: ScreenScaffoldWidget<PortfolioBloc, PortfolioState>(
        onCreate: (bloc) => bloc.add(const LoadPortfolioEvent()),
        onResume: (bloc) => bloc.add(const ScreenVisibleEvent()),
        drawer: context.isDesktop ? null : const DrawerWidget(),
        onDrawerChanged: (bloc, isOpened) {
          bloc.add(DrawerClickEvent(isOpened));
        },
        floatingActionButton: BlocBuilder<PortfolioBloc, PortfolioState>(
          builder: (context, state) {
            return state is LoadedState
                ? const AssistantLauncherWidget()
                : const SizedBox.shrink();
          },
        ),
        body: const ContentWidget(),
      ),
    );
  }
}
