part of 'content_widget.dart';

class _FaqWidget extends StatelessWidget {
  const _FaqWidget({required this.faq});

  final List<ServiceFaqEntity> faq;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          for (final (faqIndex, faqItem) in faq.indexed) ...[
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
                  faqItem.question,
                  style: context.typography.emphasizedBodyMedium,
                  color: context.colorPalette.neutral.grey10,
                ),
                children: [
                  DSTextWidget(
                    faqItem.answer,
                    style: context.typography.bodyMedium,
                    color: context.colorPalette.neutral.grey9,
                  ),
                ],
              ),
            ),
            if (faqIndex < faq.length - 1)
              Divider(
                height: 1,
                color: context.colorPalette.neutral.grey5.color.withAlpha(90),
              ),
          ],
        ],
      ),
    );
  }
}
