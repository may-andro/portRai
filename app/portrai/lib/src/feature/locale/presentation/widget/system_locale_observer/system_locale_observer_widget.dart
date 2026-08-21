import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class SystemLocaleObserverWidget extends StatefulWidget {
  const SystemLocaleObserverWidget({required this.child, super.key});

  final Widget child;

  @override
  State<SystemLocaleObserverWidget> createState() =>
      _SystemLocaleObserverWidgetState();
}

class _SystemLocaleObserverWidgetState extends State<SystemLocaleObserverWidget>
    with WidgetsBindingObserver {
  late final SystemLocaleObserverBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bloc = SystemLocaleObserverBloc(
      getLocaleUseCase: appServiceLocator.get<GetLocaleUseCase>(),
      updateLocaleUseCase: appServiceLocator.get<UpdateLocaleUseCase>(),
      logReporter: appServiceLocator.get<LogReporter>(),
    );

    _bloc.add(const LoadLocaleEvent());
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    final newLocale = locales?.first.appLocale;
    if (newLocale != null) {
      _bloc.add(LocaleUpdateEvent(newLocale));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _bloc, child: widget.child);
  }
}
