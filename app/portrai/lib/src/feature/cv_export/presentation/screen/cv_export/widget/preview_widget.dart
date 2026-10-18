part of 'content_widget.dart';

class _PreviewWidget extends StatelessWidget {
  const _PreviewWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final pdfBytes = state.pdfBytes;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final pageMargin = context.space(factor: 2);
    final loader = Center(
      child: DSLoadingWidget(size: context.space(factor: 5)),
    );

    // The preview is exactly one A4 page plus its margin.
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth - pageMargin * 2;
        final height =
            pageWidth * PdfPageFormat.a4.height / PdfPageFormat.a4.width +
            pageMargin * 2;
        return SizedBox(
          height: height,
          child: _buildPreview(
            context,
            radius: radius,
            pdfBytes: pdfBytes,
            loader: loader,
            pageMargin: pageMargin,
          ),
        );
      },
    );
  }

  Widget _buildPreview(
    BuildContext context, {
    required BorderRadius radius,
    required Uint8List? pdfBytes,
    required Widget loader,
    required double pageMargin,
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: context.colorPalette.surface.surfaceContainerHigh.color,
        child: Stack(
          children: [
            Positioned.fill(
              // One loader until the new page is ready, instead of the old page
              // followed by a second spinner.
              child: pdfBytes == null || state.isGenerating
                  ? loader
                  : PdfPreview(
                      loadingWidget: loader,
                      key: ValueKey(state.pdfRevision),
                      build: (_) => pdfBytes,
                      useActions: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      allowPrinting: false,
                      allowSharing: false,
                      previewPageMargin: EdgeInsets.all(pageMargin),
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
          ],
        ),
      ),
    );
  }
}
