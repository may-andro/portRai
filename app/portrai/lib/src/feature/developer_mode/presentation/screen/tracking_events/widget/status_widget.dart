part of 'content_widget.dart';

/// Shown before the app has sent any event.
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return _MessageWidget(
      icon: Icons.analytics_outlined,
      title: context.localizations.trackingEventsEmptyTitle,
      message: context.localizations.trackingEventsEmptyMessage,
    );
  }
}

/// Shown when the search and filters leave no event.
class _NoResultsWidget extends StatelessWidget {
  const _NoResultsWidget();

  @override
  Widget build(BuildContext context) {
    return _MessageWidget(
      icon: Icons.search_off_rounded,
      title: context.localizations.trackingEventsNoResultsTitle,
      message: context.localizations.trackingEventsNoResultsMessage,
    );
  }
}

class _MessageWidget extends StatelessWidget {
  const _MessageWidget({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Padding(
      padding: EdgeInsets.all(context.space(factor: 4)),
      child: Column(
        spacing: context.space(),
        children: [
          DSIconWidget(
            icon,
            color: palette.neutral.grey7,
            size: DSIconSize.large,
          ),
          DSTextWidget(
            title,
            style: context.typography.titleMedium,
            color: palette.neutral.grey10,
            textAlign: TextAlign.center,
          ),
          DSTextWidget(
            message,
            style: context.typography.bodyMedium,
            color: palette.neutral.grey7,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
