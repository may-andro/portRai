part of 'content_widget.dart';

class _LanguageSectionWidget extends StatelessWidget {
  const _LanguageSectionWidget({
    required this.profile,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (profile.languages.isEmpty) return const SizedBox.shrink();
    final items = profile.languages.toLanguageWidgets(context, isDesktop);
    return _SectionWidget(
      label: 'Languages',
      isDesktop: isDesktop,
      children: [
        Wrap(
          spacing: context.space(factor: 1.5),
          runSpacing: context.space(factor: 1.5),
          children: items,
        ),
      ],
    );
  }
}

extension on List<LanguageEntity> {
  List<Widget> toLanguageWidgets(BuildContext context, bool isDesktop) {
    return map((language) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: isDesktop ? 1.5 : 2),
          vertical: context.space(factor: isDesktop ? 1.25 : 1.5),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colorPalette.brand.primaryContainer.color,
              context.colorPalette.brand.secondaryContainer.color,
            ],
          ),
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: isDesktop ? 0.75 : 1),
          children: [
            Icon(
              Icons.language_rounded,
              size: (isDesktop ? DSIconSize.small : DSIconSize.medium).getSize(
                context,
              ),
              color: context.colorPalette.brand.primary.color,
            ),
            DSTextWidget(
              '${language.language} - ${language.proficiency}',
              style: isDesktop
                  ? context.typography.emphasizedBodySmall
                  : context.typography.emphasizedBodyMedium,
              color: context.colorPalette.neutral.grey9,
              maxLines: isDesktop ? 2 : null,
            ),
          ],
        ),
      );
    }).toList();
  }
}
