part of 'content_widget.dart';

class _LocaleListWidget extends StatelessWidget {
  const _LocaleListWidget({
    required this.supportedLocales,
    required this.currentLocale,
    this.targetLocale,
    required this.isLoading,
  });

  final List<Locale> supportedLocales;
  final AppLocale currentLocale;
  final AppLocale? targetLocale;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Locale>(
      groupValue: currentLocale.locale,
      onChanged: (Locale? value) {
        if (value case final Locale value
            when !isLoading && value != currentLocale.locale) {
          context.bloc.add(UpdateLocaleEvent(value));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(),
        children: supportedLocales.map((locale) {
          return _LocaleItemWidget(
            locale: locale,
            isLoading: targetLocale?.locale == locale,
            isEnabled: !isLoading,
            isSelected: currentLocale.locale == locale,
          );
        }).toList(),
      ),
    );
  }
}

class _LocaleItemWidget extends StatelessWidget {
  const _LocaleItemWidget({
    required this.locale,
    required this.isLoading,
    required this.isEnabled,
    required this.isSelected,
  });

  final Locale locale;
  final bool isLoading;
  final bool isEnabled;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        spacing: context.space(),
        children: [
          Expanded(
            child: DSTextWidget(
              locale.languageCode.languageName,
              style: context.typography.titleMedium,
              color: context.colorPalette.neutral.grey7,
            ),
          ),
          if (isLoading) ...[const _LocaleLoadingStateWidget()],
        ],
      ),
      leading: Radio<Locale>(
        value: locale,
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return context.colorPalette.semantic.success.color;
          }
          return context.colorPalette.neutral.grey5.color;
        }),
      ),
      dense: true,
      enabled: isEnabled,
      selected: isSelected,
    );
  }
}

class _LocaleLoadingStateWidget extends StatelessWidget {
  const _LocaleLoadingStateWidget();

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 2);
    return SizedBox(
      width: size,
      height: size,
      child: DSLoadingWidget(
        size: size,
        color: context.colorPalette.onBackground,
      ),
    );
  }
}
