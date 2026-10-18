part of 'content_widget.dart';

/// Download action in the page header, next to the one at the bottom.
class _HeaderActionWidget extends StatelessWidget {
  const _HeaderActionWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isReady = state.pdfBytes != null && !state.isGenerating;

    return Tooltip(
      message: context.localizations.cvExportDownload,
      child: DSIconButtonWidget(
        Icons.download_rounded,
        iconColor: palette.surface.onSurface,
        buttonColor: palette.neutral.transparent,
        isLoading: state.isDownloading,
        onPressed: isReady
            ? () => context.bloc.add(const DownloadCvClickEvent())
            : null,
      ),
    );
  }
}
