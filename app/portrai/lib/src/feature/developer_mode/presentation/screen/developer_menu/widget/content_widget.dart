import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/tracking_events_screen.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentWidget<DeveloperMenuBloc, DeveloperMenuState>(
      impressionPrefix: 'developer_menu',
      contentOf: (state) => switch (state) {
        DeveloperMenuInitialState() ||
        DeveloperMenuLoadingState() => const ScreenLoadingContent(),
        DeveloperMenuLoadedState() => ScreenLoadedContent.slivers([
          PageAppBarWidget(title: context.localizations.settingDeveloperMode),
          const _DeveloperMenuContentWidget(),
        ]),
        DeveloperMenuErrorState(:final failure) => ScreenErrorContent(failure),
      },
      onContentVisible: (content) =>
          context.bloc.add(ViewStateVisibleEvent(content.trackingLabel)),
    );
  }
}

class _DeveloperMenuContentWidget extends StatelessWidget {
  const _DeveloperMenuContentWidget();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: context.screenHorizontalPadding.copyWith(
        top: context.space(factor: 2),
        bottom: context.space(factor: 2),
      ),
      sliver: SliverToBoxAdapter(
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
                    onTap: () {
                      context.bloc.add(
                        const DeveloperMenuEntryClickEvent('feature_flags_row'),
                      );
                      FeatureFlagScreen.navigate(context);
                    },
                  ),
                  DSHorizontalDividerWidget(
                    thickness: 1,
                    color: context.colorPalette.neutral.grey3,
                  ),
                  DSLabeledInfoRowWidget(
                    icon: Icons.analytics_outlined,
                    label: context.localizations.developerMenuTrackingViewer,
                    value: context
                        .localizations
                        .developerMenuTrackingViewerDescription,
                    onTap: () {
                      context.bloc.add(
                        const DeveloperMenuEntryClickEvent(
                          'tracking_viewer_row',
                        ),
                      );
                      TrackingEventsScreen.navigate(context);
                    },
                  ),
                ],
              ),
            ),
            const DSVerticalSpacerWidget(3),

            _SectionHeader(
              title: context.localizations.developerMenuDataSource,
            ),
            const DSCardWidget(child: _AssetSourceTile()),
            const DSVerticalSpacerWidget(3),

            _SectionHeader(title: context.localizations.developerMenuAiImage),
            const DSCardWidget(
              child: Column(
                children: [_AiImageStyleTile(), _AiImageModelTile()],
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
                    title:
                        context.localizations.developerMenuForceBlacklistError,
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

class _AssetSourceTile extends StatelessWidget {
  const _AssetSourceTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeveloperMenuBloc, DeveloperMenuState>(
      buildWhen: (previous, current) => current is DeveloperMenuLoadedState,
      builder: (context, state) {
        final isTemplate =
            state is DeveloperMenuLoadedState && state.assetSource.isTemplate;
        return SwitchListTile(
          secondary: DSIconWidget(
            Icons.dataset_outlined,
            color: context.colorPalette.neutral.grey9,
            size: DSIconSize.medium,
          ),
          title: DSTextWidget(
            context.localizations.developerMenuUseTemplateData,
            style: context.typography.emphasizedBodyMedium,
            color: context.colorPalette.neutral.grey9,
          ),
          subtitle: DSTextWidget(
            context.localizations.developerMenuUseTemplateDataDescription,
            style: context.typography.emphasizedBodySmall,
            color: context.colorPalette.neutral.grey9,
          ),
          value: isTemplate,
          onChanged: (value) => context.bloc.add(
            AssetSourceClickEvent(
              value ? AssetSource.template : AssetSource.real,
            ),
          ),
        );
      },
    );
  }
}

class _AiImageStyleTile extends StatelessWidget {
  const _AiImageStyleTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeveloperMenuBloc, DeveloperMenuState>(
      buildWhen: (previous, current) => current is DeveloperMenuLoadedState,
      builder: (context, state) {
        final selected = state is DeveloperMenuLoadedState
            ? state.aiImageSettings.style
            : AiImageStyle.avatar;
        return _PickerTile<AiImageStyle>(
          icon: Icons.brush_outlined,
          title: context.localizations.developerMenuAiImageStyle,
          subTitle: context.localizations.developerMenuAiImageStyleDescription,
          value: selected,
          options: AiImageStyle.values,
          labelOf: (style) => style.label,
          onChanged: (style) => context.bloc.add(AiImageStyleClickEvent(style)),
        );
      },
    );
  }
}

class _AiImageModelTile extends StatelessWidget {
  const _AiImageModelTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeveloperMenuBloc, DeveloperMenuState>(
      buildWhen: (previous, current) => current is DeveloperMenuLoadedState,
      builder: (context, state) {
        final selected = state is DeveloperMenuLoadedState
            ? state.aiImageSettings.model
            : AiImageModelType.geminiFlashImage;
        return _PickerTile<AiImageModelType>(
          icon: Icons.memory_outlined,
          title: context.localizations.developerMenuAiImageModel,
          subTitle: context.localizations.developerMenuAiImageModelDescription,
          value: selected,
          options: AiImageModelType.values,
          labelOf: (model) => model.label,
          onChanged: (model) => context.bloc.add(AiImageModelClickEvent(model)),
        );
      },
    );
  }
}

class _PickerTile<T> extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subTitle;
  final T value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.space()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSIconWidget(
                icon,
                color: context.colorPalette.neutral.grey9,
                size: DSIconSize.medium,
              ),
              const DSHorizontalSpacerWidget(2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSTextWidget(
                      title,
                      style: context.typography.emphasizedBodyMedium,
                      color: context.colorPalette.neutral.grey9,
                    ),
                    DSTextWidget(
                      subTitle,
                      style: context.typography.emphasizedBodySmall,
                      color: context.colorPalette.neutral.grey9,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const DSVerticalSpacerWidget(1),
          DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text(labelOf(option), overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ],
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
