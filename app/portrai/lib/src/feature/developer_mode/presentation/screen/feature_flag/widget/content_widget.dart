import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:tracking/tracking.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagBloc, FeatureFlagState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          FeatureFlagInitialState() ||
          FeatureFlagLoadingState() => const _LoadingWidget(),
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

  final FeatureFlagLoadedState state;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: 'feature_flag_loaded_content_view',
      onImpression: () => context.bloc.add(ViewStateVisibleEvent.success()),
      child: DSResponsiveContainerWidget(
        mobileBuilder: (_) => _FeatureFlagContentWidget(state),
        tabletBuilder: (_) => _FeatureFlagContentWidget(state),
        desktopBuilder: (_) => _FeatureFlagContentWidget(state),
      ),
    );
  }
}

class _FeatureFlagContentWidget extends StatelessWidget {
  const _FeatureFlagContentWidget(this.state);

  final FeatureFlagLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 2),
            vertical: context.space(factor: context.isDesktop ? 2 : 0),
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  'Feature Flags',
                  style: context.typography.headlineSmall,
                  color: context.colorPalette.onBackground,
                ),
                const DSVerticalSpacerWidget(3),
                const Spacer(),
                const DSVerticalSpacerWidget(2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
