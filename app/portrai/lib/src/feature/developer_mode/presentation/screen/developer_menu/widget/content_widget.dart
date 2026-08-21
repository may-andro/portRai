import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/feature_flag_screen.dart';
import 'package:tracking/tracking.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeveloperMenuBloc, DeveloperMenuState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          DeveloperMenuInitialState() ||
          DeveloperMenuLoadingState() => const _LoadingWidget(),
          final DeveloperMenuLoadedState state => _SuccessWidget(state: state),
          final DeveloperMenuErrorState state => _ErrorWidget(
            message: state.message,
          ),
        };
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'developer_menu_loading_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.loading()),
      child: DSLoadingWidget(
        size: max(context.shortestSide * 0.1, context.space(factor: 2)),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'developer_menu_error_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: DSErrorCardWidget(message: message),
        ),
      ),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget({required this.state});

  final DeveloperMenuLoadedState state;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'developer_menu_loaded_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
        mobileBuilder: (_) => _DeveloperMenuContentWidget(state),
        tabletBuilder: (_) => _DeveloperMenuContentWidget(state),
        desktopBuilder: (_) => _DeveloperMenuContentWidget(state),
      ),
    );
  }
}

class _DeveloperMenuContentWidget extends StatelessWidget {
  const _DeveloperMenuContentWidget(this.state);

  final DeveloperMenuLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 2),
            vertical: context.space(factor: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation section
              const _SectionHeader(title: 'Controls & Tools'),
              DSCardWidget(
                child: Column(
                  children: [
                    DSLabeledInfoRowWidget(
                      icon: Icons.storage_outlined,
                      label: 'Cache Playground',
                      value: 'Play with cache content and behavior',
                      onTap: () {},
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    DSLabeledInfoRowWidget(
                      icon: Icons.flag_outlined,
                      label: 'Feature Flags',
                      value: 'View and manage feature flags in the app',
                      onTap: () => FeatureFlagScreen.navigate(context),
                    ),
                  ],
                ),
              ),
              const DSVerticalSpacerWidget(3),

              // Actions section
              const _SectionHeader(title: 'Error Simulation'),
              DSCardWidget(
                child: Column(
                  children: [
                    _ActionTile(
                      title: 'Force Fatal Crash',
                      subTitle: 'Simulate a fatal crash in the app',
                      icon: Icons.warning_amber_outlined,
                      onPressed: () =>
                          context.bloc.add(const ForceFatalCrashEvent()),
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    _ActionTile(
                      title: 'Force Non-Fatal Crash',
                      subTitle: 'Simulate a non-fatal crash in the app',
                      icon: Icons.error_outline,
                      onPressed: () =>
                          context.bloc.add(const ForceNonFatalCrashEvent()),
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    _ActionTile(
                      title: 'Force Blacklist Error',
                      subTitle:
                          'Simulate an error that should be ignored by the error handler',
                      icon: Icons.block_outlined,
                      onPressed: () =>
                          context.bloc.add(const ForceBlacklistErrorEvent()),
                    ),
                  ],
                ),
              ),
              const DSVerticalSpacerWidget(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.space(factor: 0.5),
        bottom: context.space(),
      ),
      child: DSTextWidget(
        title,
        style: context.typography.emphasizedTitleSmall,
        color: context.colorPalette.neutral.grey10,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: DSIconWidget(
        icon,
        color: context.colorPalette.neutral.grey9,
        size: DSIconSize.medium,
      ),
      title: DSTextWidget(
        title,
        style: context.typography.emphasizedBodyMedium,
        color: context.colorPalette.neutral.grey9,
      ),
      subtitle: DSTextWidget(
        subTitle,
        style: context.typography.emphasizedBodySmall,
        color: context.colorPalette.neutral.grey9,
      ),
      onTap: onPressed,
    );
  }
}
