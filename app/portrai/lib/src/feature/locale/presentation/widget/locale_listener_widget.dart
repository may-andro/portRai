import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class LocaleListenerWidget extends StatelessWidget {
  const LocaleListenerWidget({super.key, required this.builder});

  final Widget Function(BuildContext context, AppLocale appLocale) builder;

  @override
  Widget build(BuildContext context) {
    final appLocale = appServiceLocator.get<AppLocale>();
    final localeStream = appServiceLocator.get<GetLocaleStreamUseCase>().call();

    return StreamBuilder<AppLocale>(
      stream: localeStream,
      initialData: appLocale,
      builder: (context, asyncSnapshot) {
        return builder(context, asyncSnapshot.data ?? appLocale);
      },
    );
  }
}
