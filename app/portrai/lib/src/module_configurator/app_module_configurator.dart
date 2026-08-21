import 'dart:async';

import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/error_reporter/app_blacklist_error_handler.dart';
import 'package:portrai/src/error_reporter/app_fatal_exception_handler.dart';
import 'package:portrai/src/utility/log_use_case_interceptor.dart';
import 'package:use_case/use_case.dart';

class AppModuleConfigurator implements ModuleConfigurator {
  AppModuleConfigurator(this._buildConfig);

  final BuildConfig _buildConfig;

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) {
    final errorReporter = serviceLocator.get<ErrorReporter>();

    /// uncaught asynchronous errors that aren't handled by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      errorReporter.globalErrorHandler(error, stack);
      return true;
    };

    /// set use case interceptor
    serviceLocator.get<UseCaseInterceptorController>().register(
      serviceLocator.get<LogUseCaseInterceptor>(),
    );

    /// set blacklist error
    serviceLocator.get<BlacklistErrorController>().register(
      AppBlacklistErrorHandler(),
    );

    /// set fatal error handler
    serviceLocator.get<FatalErrorController>().register(AppFatalErrorHandler());
  }

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) => null;

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => _buildConfig);
  }
}
