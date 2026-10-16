part of 'footer_widget.dart';

class _FestiveBannerWidget extends StatelessWidget {
  const _FestiveBannerWidget();

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final festival = switch (context.theme.designSystem) {
      DesignSystem.beltane => localizations.festivalNameBeltane,
      DesignSystem.carnival => localizations.festivalNameCarnival,
      DesignSystem.chuseok => localizations.festivalNameChuseok,
      DesignSystem.diwali => localizations.festivalNameDiwali,
      DesignSystem.halloween => localizations.festivalNameHalloween,
      DesignSystem.hogeras => localizations.festivalNameHogeras,
      DesignSystem.hogmanay => localizations.festivalNameHogmanay,
      DesignSystem.holi => localizations.festivalNameHoli,
      DesignSystem.obon => localizations.festivalNameObon,
      DesignSystem.pachamama => localizations.festivalNamePachamama,
      DesignSystem.sakura => localizations.festivalNameSakura,
      DesignSystem.xmas => localizations.festivalNameXmas,
    };
    final color = context.colorPalette.onInverseSurface;
    final radius = Radius.circular(context.space(factor: 2));
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 2),
        vertical: context.space(factor: 0.75),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: radius),
        color: color.color.withValues(alpha: 0.18),
      ),
      child: DSTextWidget(
        localizations.festiveBannerTitle(festival),
        style: context.typography.labelLarge,
        color: color,
        textAlign: TextAlign.center,
      ),
    );
  }
}
