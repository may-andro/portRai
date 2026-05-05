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
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.appAttest,
      );
      await _firebaseAppCheck.setTokenAutoRefreshEnabled(true);
    } catch (e, st) {
      throw AppCheckException(e.toString(), st);
    }
  }
}
