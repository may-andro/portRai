import 'dart:async';
import 'dart:io';

import 'package:error_reporter/error_reporter.dart';
import 'package:flutter/foundation.dart';

class AppFatalErrorHandler implements FatalErrorHandler {
  @override
  FutureOr<void> onFatalError(Object error) {
    // exit() is unsupported on web and would only throw a second error.
    if (kIsWeb) return null;
    exit(1);
  }
}
