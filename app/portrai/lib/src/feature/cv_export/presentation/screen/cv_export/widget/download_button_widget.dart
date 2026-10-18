part of 'content_widget.dart';

class _DownloadButtonWidget extends StatelessWidget {
  const _DownloadButtonWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorPalette.surface.surfaceContainerLow.color,
        border: Border(
          top: BorderSide(
            color: context.colorPalette.outline.outlineVariant.color,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: SizedBox(
            width: double.infinity,
            child: DSButtonWidget(
              label: context.localizations.cvExportDownload,
              icon: Icons.download_rounded,
              isLoading: state.isDownloading,
              isDisabled: state.pdfBytes == null || state.isGenerating,
              onPressed: () => context.bloc.add(const DownloadCvClickEvent()),
            ),
          ),
        ),
      ),
    );
  }
}
