import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
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
          DeveloperMenuLoadedState() => const _SuccessWidget(),
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
  const _SuccessWidget();

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'developer_menu_loaded_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
        mobileBuilder: (_) => const _DeveloperMenuContentWidget(),
        tabletBuilder: (_) => const _DeveloperMenuContentWidget(),
        desktopBuilder: (_) => const _DeveloperMenuContentWidget(),
      ),
    );
  }
}

class _DeveloperMenuContentWidget extends StatelessWidget {
  const _DeveloperMenuContentWidget();

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
              _SectionHeader(
                title: context.localizations.developerMenuControlsAndTools,
              ),
              DSCardWidget(
                child: Column(
                  children: [
                    DSLabeledInfoRowWidget(
                      icon: Icons.storage_outlined,
                      label: context.localizations.developerMenuCachePlayground,
                      value: context
                          .localizations
                          .developerMenuCachePlaygroundDescription,
                      onTap: () {},
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    DSLabeledInfoRowWidget(
                      icon: Icons.flag_outlined,
                      label: context.localizations.developerMenuFeatureFlags,
                      value: context
                          .localizations
                          .developerMenuFeatureFlagsDescription,
                      onTap: () => FeatureFlagScreen.navigate(context),
                    ),
                  ],
                ),
              ),
              const DSVerticalSpacerWidget(3),

              _SectionHeader(
                title: context.localizations.developerMenuErrorSimulation,
              ),
              DSCardWidget(
                child: Column(
                  children: [
                    _ActionTile(
                      title: context.localizations.developerMenuForceFatalCrash,
                      subTitle: context
                          .localizations
                          .developerMenuForceFatalCrashDescription,
                      icon: Icons.warning_amber_outlined,
                      onPressed: () =>
                          context.bloc.add(const ForceFatalCrashEvent()),
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    _ActionTile(
                      title:
                          context.localizations.developerMenuForceNonFatalCrash,
                      subTitle: context
                          .localizations
                          .developerMenuForceNonFatalCrashDescription,
                      icon: Icons.error_outline,
                      onPressed: () =>
                          context.bloc.add(const ForceNonFatalCrashEvent()),
                    ),
                    DSHorizontalDividerWidget(
                      thickness: 1,
                      color: context.colorPalette.neutral.grey3,
                    ),
                    _ActionTile(
                      title: context
                          .localizations
                          .developerMenuForceBlacklistError,
                      subTitle: context
                          .localizations
                          .developerMenuForceBlacklistErrorDescription,
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
