part of 'content_widget.dart';

class _AssistantGenuiSurfaceWidget extends StatefulWidget {
  const _AssistantGenuiSurfaceWidget({
    super.key,
    required this.session,
    required this.surfaceId,
  });

  final AssistantGenuiSession session;
  final String surfaceId;

  @override
  State<_AssistantGenuiSurfaceWidget> createState() =>
      _AssistantGenuiSurfaceWidgetState();
}

class _AssistantGenuiSurfaceWidgetState
    extends State<_AssistantGenuiSurfaceWidget> {
  late void Function() _releaseSurface;

  @override
  void initState() {
    super.initState();
    _releaseSurface = widget.session.acquireSurface();
  }

  @override
  void didUpdateWidget(covariant _AssistantGenuiSurfaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.session, widget.session)) {
      _releaseSurface();
      _releaseSurface = widget.session.acquireSurface();
    }
  }

  @override
  void dispose() {
    _releaseSurface();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: context.space()),
    child: Surface(
      surfaceContext: widget.session.controller.contextFor(widget.surfaceId),
    ),
  );
}
