import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:log_reporter/src/log/composite_log_reporter.dart';
import 'package:log_reporter/src/log/firebase_log_reporter.dart';
import 'package:log_reporter/src/log/local_log_reporter.dart';
import 'package:log_reporter/src/log/log_reporter.dart';
import 'package:logger/logger.dart';
import 'package:module_injector/module_injector.dart';

class LogReporterModuleConfigurator implements ModuleConfigurator {
  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) {
    serviceLocator.get<LogReporter>().debug(
      'Log reporter initialised successfully',
    );
  }

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) => null;

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => Logger());
    final localLogReporter = LocalLogReporter(serviceLocator.get<Logger>());

    final firebaseLogReporter = FirebaseLogReporter(
      serviceLocator.get<FbCrashlyticsController>(),
    );

    serviceLocator.registerSingleton<LogReporter>(
      () => CompositeLogReporter([firebaseLogReporter, localLogReporter]),
    );
  }
}
