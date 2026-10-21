import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase/src/ai/fb_ai_backend.dart';
import 'package:firebase/src/ai/fb_ai_controller.dart';
import 'package:firebase/src/analytics/fb_analytics_controller.dart';
import 'package:firebase/src/app_check/fb_app_check_controller.dart';
import 'package:firebase/src/auth/fb_auth_controller.dart';
import 'package:firebase/src/crashlytics/fb_crashlytics_controller.dart';
import 'package:firebase/src/firestore/fb_firestore_controller.dart';
import 'package:firebase/src/function/fb_function_controller.dart';
import 'package:firebase/src/remote_config/fb_remote_config_controller.dart';
import 'package:firebase/src/storage/fb_storage_controller.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:module_injector/module_injector.dart';

class FirebaseModuleConfigurator implements ModuleConfigurator {
  FirebaseModuleConfigurator({
    required this.isFirebaseEnabled,
    required this.firebaseOptions,
    required this.appCheckWebSiteKey,
    required this.storageBucketUrl,
    this.aiBackend = FbAiBackend.googleAI,
    this.aiLocation = 'global',
    this.aiUseLimitedUseAppCheckTokens = true,
  });

  final bool isFirebaseEnabled;
  final FirebaseOptions firebaseOptions;
  final String appCheckWebSiteKey;
  final String storageBucketUrl;
  final FbAiBackend aiBackend;
  final String aiLocation;

  /// Replay protection: every AI request carries a fresh single-use App Check
  /// token. Costs one attestation per request; enforcement itself is enabled
  /// for Firebase AI Logic in the console.
  final bool aiUseLimitedUseAppCheckTokens;

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) async {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) async {
    final appCheckController = serviceLocator.get<FbAppCheckController>();
    // App Check goes first so later requests carry its token.
    await appCheckController.initialiseAppCheck(webSiteKey: appCheckWebSiteKey);

    final crashlyticsController = serviceLocator.get<FbCrashlyticsController>();
    final rcController = serviceLocator.get<FbRemoteConfigController>();
    final analyticsController = serviceLocator.get<FbAnalyticsController>();
    await Future.wait([
      _setUpCrashlytics(crashlyticsController),
      rcController.initialiseRemoteConfig(defaultConfigsMap: const {}),
      analyticsController.enableFirebaseAnalytics(isFirebaseEnabled),
    ]);
  }

  Future<void> _setUpCrashlytics(FbCrashlyticsController controller) async {
    await controller.setCrashlyticsEnabled(isFirebaseEnabled);
    await controller.logMessage('App Started');
  }

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) async {
    _injectAppCheck(serviceLocator);
    _injectAuth(serviceLocator);
    _injectCrashlytics(serviceLocator);
    await _injectRemoteConfig(serviceLocator);
    _injectAnalytics(serviceLocator);
    _injectFirestore(serviceLocator);
    _injectStorage(serviceLocator);
    _injectFunctions(serviceLocator);
    _injectAi(serviceLocator);
  }

  void _injectAppCheck(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseAppCheck.instance);
    serviceLocator.registerFactory(
      () => FbAppCheckController(serviceLocator.get<FirebaseAppCheck>()),
    );
  }

  void _injectAi(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(
      () => switch (aiBackend) {
        FbAiBackend.googleAI => FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: aiUseLimitedUseAppCheckTokens,
        ),
        FbAiBackend.agentPlatform => FirebaseAI.agentPlatform(
          location: aiLocation,
          useLimitedUseAppCheckTokens: aiUseLimitedUseAppCheckTokens,
        ),
      },
    );
    serviceLocator.registerFactory(
      () => FbAiController(serviceLocator.get<FirebaseAI>()),
    );
  }

  void _injectAuth(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseAuth.instance);
    serviceLocator.registerFactory(
      () => FbAuthController(serviceLocator.get<FirebaseAuth>()),
    );
  }

  void _injectCrashlytics(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseCrashlytics.instance);
    serviceLocator.registerFactory(
      () => FbCrashlyticsController(serviceLocator.get<FirebaseCrashlytics>()),
    );
  }

  Future<void> _injectRemoteConfig(ServiceLocator serviceLocator) async {
    serviceLocator.registerSingleton(() => FirebaseRemoteConfig.instance);
    serviceLocator.registerFactory(
      () =>
          FbRemoteConfigController(serviceLocator.get<FirebaseRemoteConfig>()),
    );
  }

  void _injectAnalytics(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseAnalytics.instance);
    serviceLocator.registerFactory(
      () => FirebaseAnalyticsObserver(
        analytics: serviceLocator.get<FirebaseAnalytics>(),
      ),
    );
    serviceLocator.registerFactory(
      () => FbAnalyticsController(serviceLocator.get<FirebaseAnalytics>()),
    );
  }

  void _injectFirestore(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseFirestore.instance);
    serviceLocator.registerFactory(
      () => FbFirestoreController(serviceLocator.get<FirebaseFirestore>()),
    );
  }

  void _injectStorage(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(() => FirebaseStorage.instance);
    serviceLocator.registerFactory(
      () => FbStorageController(
        serviceLocator.get<FirebaseStorage>(),
        storageBucketUrl,
      ),
    );
  }

  void _injectFunctions(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton(
      () => FirebaseFunctions.instanceFor(region: 'europe-west3'),
    );
    serviceLocator.registerFactory(
      () => FbFunctionController(
        serviceLocator.get<FirebaseFunctions>(),
        serviceLocator.get<FbAuthController>(),
      ),
    );
  }
}
