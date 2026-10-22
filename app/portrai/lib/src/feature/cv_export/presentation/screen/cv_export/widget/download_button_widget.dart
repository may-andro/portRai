part of 'content_widget.dart';

/// Download action for the loaded CV; shows nothing until the CV is loaded.
class DownloadButtonWidget extends StatelessWidget {
  const DownloadButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvExportBloc, CvExportState>(
      builder: (context, state) {
        if (state is! CvExportLoadedState) return const SizedBox.shrink();
        final isReady = state.pdfBytes != null && !state.isGenerating;

        return DSButtonWidget(
          label: context.localizations.cvExportDownload,
          icon: Icons.download_rounded,
          isLoading: state.isDownloading,
          isDisabled: !isReady,
          isExpanded: false,
          onPressed: () => context.bloc.add(const DownloadCvClickEvent()),
        );
      },
    );
  }
}
