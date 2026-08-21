import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';

@register
class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this.logReporter);

  final LogReporter logReporter;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logReporter.debug('${bloc.runtimeType} $change', tag: 'AppBlocObserver');
  }
}
