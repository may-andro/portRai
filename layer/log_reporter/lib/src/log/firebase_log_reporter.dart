import 'package:firebase/firebase.dart';
import 'package:log_reporter/src/log/log_reporter.dart';

class FirebaseLogReporter implements LogReporter {
  FirebaseLogReporter(this._fbCrashlyticsController);

  /// Crashlytics keeps only the most recent 64 KB of log lines, so a log line
  /// carries the top frames of a stack trace rather than all of it.
  static const _stackTraceFrameLimit = 8;

  final FbCrashlyticsController _fbCrashlyticsController;

  @override
  void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  }) {
    _logMessage(_logLine(message, tag, stacktrace));
  }

  @override
  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  }) {
    _logMessage(_logLine(message, tag, stacktrace));
  }

  String _logLine(String message, String? tag, StackTrace? stacktrace) {
    final taggedMessage = '[$tag] $message';
    if (stacktrace == null) return taggedMessage;

    final topFrames = stacktrace
        .toString()
        .trimRight()
        .split('\n')
        .take(_stackTraceFrameLimit)
        .join('\n');
    return '$taggedMessage\n$topFrames';
  }

  void _logMessage(String message) =>
      _fbCrashlyticsController.logMessage(message);
}
