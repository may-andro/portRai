part of 'service_detail_widget.dart';

class _FaqWidget extends StatelessWidget {
  const _FaqWidget({required this.faq});

  final List<ServiceFaqEntity> faq;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.space(factor: 1.5)),
        child: Column(
          children: [
            for (final item in faq)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(bottom: context.space()),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  expandedAlignment: Alignment.centerLeft,
                  title: DSTextWidget(
                    item.question,
                    style: context.typography.emphasizedBodyMedium,
                    color: context.colorPalette.neutral.grey10,
                  ),
                  children: [
                    DSTextWidget(
                      item.answer,
                      style: context.typography.bodyMedium,
                      color: context.colorPalette.neutral.grey9,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
