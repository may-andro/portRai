part of 'content_widget.dart';

/// Floating download action in the bottom corner.
class _DownloadButtonWidget extends StatelessWidget {
  const _DownloadButtonWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final isReady = state.pdfBytes != null && !state.isGenerating;

    return DSButtonWidget(
      label: context.localizations.cvExportDownload,
      icon: Icons.download_rounded,
      isLoading: state.isDownloading,
      isDisabled: !isReady,
      isExpanded: false,
      onPressed: () => context.bloc.add(const DownloadCvClickEvent()),
    );
  }
}
