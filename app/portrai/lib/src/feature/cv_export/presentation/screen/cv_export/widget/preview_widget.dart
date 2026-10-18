part of 'content_widget.dart';

class _PreviewWidget extends StatelessWidget {
  const _PreviewWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final pdfBytes = state.pdfBytes;

    return Stack(
      children: [
        Positioned.fill(
          child: pdfBytes == null
              ? const SizedBox.shrink()
              : PdfPreview(
                  key: ValueKey(state.pdfRevision),
                  build: (_) => pdfBytes,
                  useActions: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: false,
                  allowSharing: false,
                  scrollViewDecoration: BoxDecoration(
                    color: context.colorPalette.surface.surfaceContainer.color,
                  ),
                ),
        ),
        if (state.isGenerating)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
