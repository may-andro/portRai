import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:tracking/tracking.dart';
import 'package:use_case/use_case.dart';

/// What a screen shows for its current bloc state.
sealed class ScreenContent {
  const ScreenContent();

  /// Label reported when this content is first seen.
  String get trackingLabel;
}

final class ScreenLoadingContent extends ScreenContent {
  const ScreenLoadingContent({this.message});

  /// Shown under the loader when given.
  final String? message;

  @override
  String get trackingLabel => 'loading_content_view';
}

final class ScreenErrorContent extends ScreenContent {
  /// Shows the translated [failure], or the generic error when it is null.
  const ScreenErrorContent(this.failure, {this.onRetry}) : message = null;

  /// Shows [message] as it is, for errors the screen words itself.
  const ScreenErrorContent.message(String this.message, {this.onRetry})
    : failure = null;

  final Failure? failure;
  final String? message;

  /// Shows a retry button on the error card when given.
  final VoidCallback? onRetry;

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
/// for the state of bloc [B]. When [onContentVisible] is given, it is called
/// the first time each one is seen.
///
/// Loading always shows the lottie loader so every screen looks the same.
/// Rebuilds only when the state type changes unless [buildWhen] is given.
class ScreenContentWidget<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const ScreenContentWidget({
    required this.contentOf,
    this.impressionPrefix,
    this.onContentVisible,
    this.buildWhen,
    super.key,
  }) : assert(
         onContentVisible == null || impressionPrefix != null,
         'An impressionPrefix is needed to report content impressions',
       );

  /// Prefix that keeps this screen's impressions apart from other screens'.
  /// Needed when [onContentVisible] is given.
  final String? impressionPrefix;
  final ScreenContent Function(S state) contentOf;
  final ValueChanged<ScreenContent>? onContentVisible;
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      buildWhen:
          buildWhen ??
          (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        final content = contentOf(state);
        final child = switch (content) {
          ScreenLoadedContent(:final child) => child,
          _ => Center(child: _statusWidgetFor(content)),
        };
        final onContentVisible = this.onContentVisible;
        if (onContentVisible == null) return child;
        return TrackingImpressionDetectorWidget(
          key: ValueKey(content.trackingLabel),
          impressionId: '${impressionPrefix}_${content.trackingLabel}',
          onImpression: () => onContentVisible(content),
          child: child,
        );
      },
    );
  }
}

/// [ScreenContentWidget] for a section of a scroll view: the loaded
/// [ScreenLoadedContent.child] must be a sliver, and loading and error are
/// shown as box slivers.
///
/// Rebuilds only when the state type changes unless [buildWhen] is given.
class ScreenContentSliverWidget<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const ScreenContentSliverWidget({
    required this.contentOf,
    this.buildWhen,
    super.key,
  });

  final ScreenContent Function(S state) contentOf;
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      buildWhen:
          buildWhen ??
          (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        final content = contentOf(state);
        return switch (content) {
          ScreenLoadedContent(:final child) => child,
          _ => SliverToBoxAdapter(child: _statusWidgetFor(content)),
        };
      },
    );
  }
}

/// The loader or error card for [content], which is not loaded content.
Widget _statusWidgetFor(ScreenContent content) {
  return Builder(
    builder: (context) => switch (content) {
      ScreenLoadingContent(:final message) => Padding(
        padding: EdgeInsets.all(context.space()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 2),
          children: [
            DSLoadingWidget(
              style: DSLoadingStyle.lottie,
              size: max(context.shortestSide * 0.1, context.space(factor: 2)),
            ),
            if (message != null)
              DSTextWidget(
                message,
                style: context.typography.bodyMedium,
                color: context.colorPalette.neutral.grey7,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
      ScreenErrorContent(:final failure, :final message, :final onRetry) =>
        Padding(
          padding: EdgeInsets.all(context.space()),
          child: DSErrorCardWidget(
            message:
                message ??
                FailureTranslator.translate(
                  context,
                  failure ?? const UnknownFailure(),
                ),
            onRetryClicked: onRetry,
            title: context.localizations.errorTitle,
            retryLabel: context.localizations.retry,
          ),
        ),
      ScreenLoadedContent(:final child) => child,
    },
  );
}
