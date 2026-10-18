part of 'content_widget.dart';

class _FailureWidget extends StatelessWidget {
  const _FailureWidget({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.space()),
      child: DSTextWidget(
        FailureTranslator.translate(context, failure),
        style: context.typography.bodySmall,
        color: context.colorPalette.semantic.error,
      ),
    );
  }
}
