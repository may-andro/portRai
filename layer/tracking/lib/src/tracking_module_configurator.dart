import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/reporter.dart';

class TrackingModuleConfigurator implements ModuleConfigurator {
  TrackingModuleConfigurator(
    this.isFirebaseEnabled, {
    this.keepsSentEvents = kDebugMode,
  });

  final bool isFirebaseEnabled;

  /// Whether sent events are also kept in memory by a [LocalTrackingReporter]
  /// for inspection. Defaults to debug builds only.
  final bool keepsSentEvents;

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) {
    serviceLocator.get<TrackingReporter>().sendTrackingEvent(
      AppStartTracking(),
    );
  }

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) => null;

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    final firebaseTrackingReporter = FirebaseTrackingReporter(
      serviceLocator.get<FbAnalyticsController>(),
    );
    serviceLocator.registerSingleton<TrackingReporter>(
      () => CompositeTrackingReporter([
        if (isFirebaseEnabled) firebaseTrackingReporter,
        if (keepsSentEvents) LocalTrackingReporter(),
      ]),
    );
  }
}
