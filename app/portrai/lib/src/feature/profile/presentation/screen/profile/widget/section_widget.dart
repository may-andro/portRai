part of 'content_widget.dart';

class _DownloadResumeButtonWidget extends StatelessWidget {
  const _DownloadResumeButtonWidget({required this.resumeUrl});

  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    return HoverLiftWidget(
      child: DSButtonWidget(
        label: context.localizations.profileDownloadResumeButton,
        icon: Icons.download_rounded,
        variant: DSButtonVariant.secondary,
        isExpanded: false,
        onPressed: () {
          context.bloc.add(
            OpenExternalUrlEvent(url: resumeUrl, label: 'Resume'),
          );
        },
      ),
    );
  }
}
