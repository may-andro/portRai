part of 'service_detail_widget.dart';

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 8);

    return Row(
      spacing: context.space(factor: 2),
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(context.space(factor: 0.75)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel2.value,
            ),
            border: Border.all(color: context.colorPalette.neutral.grey5.color),
          ),
          child: DSNetworkImageWidget(url: service.image, fit: BoxFit.contain),
        ),
        Expanded(
          child: DSTextWidget(
            service.title,
            style: context.typography.emphasizedTitleLarge,
            color: context.colorPalette.neutral.grey10,
          ),
        ),
        IconButton(
          tooltip: context.localizations.close,
          onPressed: context.popScreen,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}
