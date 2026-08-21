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

  Future<void> initialiseAppCheck(String token) async {
    try {
      await _firebaseAppCheck.activate(
        providerWeb: ReCaptchaV3Provider(token),
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestProvider(),
      );
      await _firebaseAppCheck.setTokenAutoRefreshEnabled(true);
    } catch (e, st) {
      throw AppCheckException(e.toString(), st);
    }
  }
}
