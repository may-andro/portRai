import 'package:core/core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckException implements AppException {
  AppCheckException(this.cause, this.stackTrace);

  final Object cause;
  final StackTrace stackTrace;
}

class FbAppCheckController {
  FbAppCheckController(this._firebaseAppCheck);

  final FirebaseAppCheck _firebaseAppCheck;

  Future<void> initialiseAppCheck({
    required String webSiteKey,
    bool useDebugProviders = kDebugMode,
    String androidDebugToken = const String.fromEnvironment(
      'FIREBASE_APP_CHECK_ANDROID_DEBUG_TOKEN',
    ),
    String appleDebugToken = const String.fromEnvironment(
      'FIREBASE_APP_CHECK_APPLE_DEBUG_TOKEN',
    ),
    String webDebugToken = const String.fromEnvironment(
      'FIREBASE_APP_CHECK_WEB_DEBUG_TOKEN',
    ),
  }) async {
    try {
      if (kIsWeb && !useDebugProviders && webSiteKey.trim().isEmpty) {
        throw StateError(
          'FIREBASE_APP_CHECK_WEB_SITE_KEY is required for web profile '
          'and release builds.',
        );
      }
      await _firebaseAppCheck.activate(
        providerWeb: useDebugProviders
            ? WebDebugProvider(debugToken: _optionalToken(webDebugToken))
            : ReCaptchaEnterpriseProvider(webSiteKey),
        providerAndroid: useDebugProviders
            ? AndroidDebugProvider(
                debugToken: _optionalToken(androidDebugToken),
              )
            : const AndroidPlayIntegrityProvider(),
        providerApple: useDebugProviders
            ? AppleDebugProvider(debugToken: _optionalToken(appleDebugToken))
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
      await _firebaseAppCheck.setTokenAutoRefreshEnabled(true);
    } catch (e, st) {
      Error.throwWithStackTrace(AppCheckException(e, st), st);
    }
  }

  String? _optionalToken(String token) =>
      token.trim().isEmpty ? null : token.trim();
}
