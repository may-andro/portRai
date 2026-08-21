import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/widget/feature_flag_content_widget.dart';
import 'package:tracking/tracking.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagBloc, FeatureFlagState>(
      builder: (context, state) {
        return switch (state) {
          FeatureFlagInitialState() ||
          FeatureFlagLoadingState() =>
            const _LoadingWidget(),
          final FeatureFlagLoadedState state => _SuccessWidget(state: state),
          final FeatureFlagErrorState state => _ErrorWidget(
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
      impressionId: 'feature_flag_loading_content_view',
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
      impressionId: 'feature_flag_error_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.error()),
      child: Center(
        child: DSTextWidget(
          message,
          style: context.typography.bodyLarge,
          color: context.colorPalette.semantic.error,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  const _SuccessWidget({required this.state});

  final FeatureFlagLoadedState state;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'feature_flag_loaded_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
        key: ValueKey('feature_flag_content_${state.viewMode}_${state.searchQuery}_${state.allFlags.length}'),
        mobileBuilder: (_) => FeatureFlagContentWidget(state),
        tabletBuilder: (_) => FeatureFlagContentWidget(state),
        desktopBuilder: (_) => FeatureFlagContentWidget(state),
      ),
    );
  }
}
