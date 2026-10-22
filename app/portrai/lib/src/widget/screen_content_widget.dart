import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:tracking/tracking.dart';
import 'package:use_case/use_case.dart';

/// What a screen shows for its current bloc state.
sealed class ScreenContent {
  const ScreenContent();

  /// Label reported when this content is first seen.
  String get trackingLabel;
}

final class ScreenLoadingContent extends ScreenContent {
  const ScreenLoadingContent({this.style = DSLoadingStyle.dots});

  final DSLoadingStyle style;

  @override
  String get trackingLabel => 'loading_content_view';
}

final class ScreenErrorContent extends ScreenContent {
  const ScreenErrorContent(this.failure);

  final Failure failure;

  @override
  String get trackingLabel => 'error_content_view';
}

final class ScreenLoadedContent extends ScreenContent {
  const ScreenLoadedContent(this.child);

  final Widget child;

  @override
  String get trackingLabel => 'loaded_content_view';
}

/// Builds the loading indicator, error card or loaded [ScreenLoadedContent.child]
/// for the state of bloc [B], and calls [onContentVisible] the first time
/// each one is seen.
///
/// Rebuilds only when the state type changes unless [buildWhen] is given.
class ScreenContentWidget<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const ScreenContentWidget({
    required this.impressionPrefix,
    required this.contentOf,
    required this.onContentVisible,
    this.buildWhen,
    super.key,
  });

  /// Prefix that keeps this screen's impressions apart from other screens'.
  final String impressionPrefix;
  final ScreenContent Function(S state) contentOf;
  final ValueChanged<ScreenContent> onContentVisible;
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      buildWhen:
          buildWhen ??
          (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        final content = contentOf(state);
        return TrackingImpressionDetectorWidget(
          key: ValueKey(content.trackingLabel),
          impressionId: '${impressionPrefix}_${content.trackingLabel}',
          onImpression: () => onContentVisible(content),
          child: switch (content) {
            ScreenLoadingContent(:final style) => DSLoadingWidget(
              style: style,
              size: max(context.shortestSide * 0.1, context.space(factor: 2)),
            ),
            ScreenErrorContent(:final failure) => Center(
              child: Padding(
                padding: EdgeInsets.all(context.space()),
                child: DSErrorCardWidget(
                  message: FailureTranslator.translate(context, failure),
                ),
              ),
            ),
            ScreenLoadedContent(:final child) => child,
          },
        );
      },
    );
  }
}
