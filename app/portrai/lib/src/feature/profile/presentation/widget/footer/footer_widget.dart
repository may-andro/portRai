import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

part 'contact_widget.dart';

part 'copytext_widget.dart';

part 'download_app_widget.dart';

part 'help_widget.dart';

part 'intro_widget.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<FooterBloc>()
          ..add(LoadDataEvent(profile: profile));
      },
      child: BlocBuilder<FooterBloc, FooterState>(
        builder: (context, state) {
          return switch (state) {
            final LoadingState _ => const _LoadingWidget(),
            final LoadedState _ => const _SuccessWidget(),
          };
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return DSLoadingWidget(
      size: max(context.shortestSide * 0.1, context.space(factor: 2)),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorPalette.surface.inverseSurface.color,
      child: SafeArea(
        child: Column(
          spacing: context.space(factor: 2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DSVerticalSpacerWidget(1),
            DSResponsiveWidthContainerWidget(
              xsBuilder: (_) => const _MobileContentWidget(),
              sBuilder: (_) => const _TabletContentWidget(),
              mBuilder: (_) => const _TabletContentWidget(),
              lBuilder: (_) => const _DesktopContentWidget(),
              xlBuilder: (_) => const _DesktopContentWidget(),
            ),
            DSHorizontalDividerWidget(
              color: context.colorPalette.border,
              thickness: 1,
            ),
            const Align(child: _CopytextWidget()),
            const DSVerticalSpacerWidget(2),
          ],
        ),
      ),
    );
  }
}

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.horizontalScreenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: const [
          _IntroWidget(),
          _ContactWidget(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_HelpWidget(), _DownloadAppWidget()],
          ),
        ],
      ),
    );
  }
}

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.horizontalScreenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 2),
        children: const [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _IntroWidget()),
              Expanded(flex: 2, child: _HelpWidget()),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _ContactWidget()),
              Expanded(flex: 2, child: _DownloadAppWidget()),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _IntroWidget(),
        _ContactWidget(),
        _DownloadAppWidget(),
        _HelpWidget(),
      ],
    );
  }
}

extension on BuildContext {
  EdgeInsets get horizontalScreenPadding => screenHorizontalPadding;
}
