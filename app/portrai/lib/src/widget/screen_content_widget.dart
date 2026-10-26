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

/// Loaded content: [ScreenLoadedContent.slivers] for screens, which always
/// end with the screen footer, or [ScreenLoadedContent.fullScreen].
final class ScreenLoadedContent extends ScreenContent {
  /// Scrollable content; the screen footer is added after [slivers].
  const ScreenLoadedContent.slivers(
    List<Widget> this.slivers, {
    this.scrollController,
  }) : child = null;

  /// Content that fills the screen and scrolls itself, such as a chat; it has
  /// no screen footer.
  const ScreenLoadedContent.fullScreen(Widget this.child)
    : slivers = null,
      scrollController = null;

  final Widget? child;
  final List<Widget>? slivers;
  final ScrollController? scrollController;

  @override
  String get trackingLabel => 'loaded_content_view';
}

/// Builds the loading indicator, error card or loaded content for the state of
/// bloc [B]. Scrollable loaded content ends with the footer from
/// [ScreenFooterProviderWidget]. When [onContentVisible] is given, it is called
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
          ScreenLoadedContent(:final slivers?, :final scrollController) =>
            _ScrollableContentWidget(
              slivers: slivers,
              scrollController: scrollController,
            ),
          ScreenLoadedContent(:final child?) => child,
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

/// [ScreenContentWidget] for a section of a scroll view: loaded content is
/// shown as slivers without a footer, and loading and error as box slivers.
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
          ScreenLoadedContent(:final slivers?) => SliverMainAxisGroup(
            slivers: slivers,
          ),
          ScreenLoadedContent(:final child?) => SliverToBoxAdapter(
            child: child,
          ),
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
      ScreenLoadedContent() => const SizedBox.shrink(),
    },
  );
}

/// Provides the footer that [ScreenContentWidget] adds after scrollable
/// loaded content.
class ScreenFooterProviderWidget extends InheritedWidget {
  const ScreenFooterProviderWidget({
    required this.footer,
    required super.child,
    super.key,
  });

  final Widget footer;

  static Widget? maybeFooterOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScreenFooterProviderWidget>()
        ?.footer;
  }

  @override
  bool updateShouldNotify(ScreenFooterProviderWidget oldWidget) {
    return footer != oldWidget.footer;
  }
}

/// Scrolls [slivers] followed by the provided screen footer, which sits at the
/// bottom of the screen when the content is shorter than it. Its text can be
/// selected and copied.
class _ScrollableContentWidget extends StatelessWidget {
  const _ScrollableContentWidget({
    required this.slivers,
    required this.scrollController,
  });

  final List<Widget> slivers;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final footer = ScreenFooterProviderWidget.maybeFooterOf(context);
    return SelectionArea(
      child: CustomScrollView(
        controller: scrollController,
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, overscroll: false),
        physics: const BouncingScrollPhysics(),
        slivers: [
          ...slivers,
          if (footer != null)
            // Fills the space left below the content, so a short screen keeps
            // the footer at the bottom and a long one has it right after the
            // content.
            SliverLayoutBuilder(
              builder: (context, constraints) => SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: max(
                      0,
                      constraints.viewportMainAxisExtent -
                          constraints.precedingScrollExtent,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: footer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
