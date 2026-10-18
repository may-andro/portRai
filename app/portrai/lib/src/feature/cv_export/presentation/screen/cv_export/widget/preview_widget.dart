part of 'content_widget.dart';

class _PreviewWidget extends StatelessWidget {
  const _PreviewWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final pdfBytes = state.pdfBytes;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);

    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: context.colorPalette.surface.surfaceContainerHigh.color,
        child: Stack(
          children: [
            Positioned.fill(
              child: pdfBytes == null
                  ? Center(
                      child: DSLoadingWidget(size: context.space(factor: 5)),
                    )
                  : PdfPreview(
                      key: ValueKey(state.pdfRevision),
                      build: (_) => pdfBytes,
                      useActions: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      allowPrinting: false,
                      allowSharing: false,
                      previewPageMargin: EdgeInsets.all(
                        context.space(factor: 2),
                      ),
                      pdfPreviewPageDecoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      scrollViewDecoration: const BoxDecoration(
                        color: Colors.transparent,
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
        ),
      ),
    );
  }
}
