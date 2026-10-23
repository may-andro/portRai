import 'package:core/core.dart';
import 'package:error_reporter/error_reporter.dart';
import 'package:mocktail/mocktail.dart';

/// Records every reported exception with its tag instead of sending it
/// anywhere. Mocktail stubs match the type argument of the generic
/// `reportError`, so a fake is used instead of a mock.
class FakeErrorReporter extends Fake implements ErrorReporter {
  final reportedErrors = <({AppException exception, String? tag})>[];

  @override
  Future<void> reportError<T extends AppException>({
    required T exception,
    required StackTrace stackTrace,
    String? tag,
  }) async {
    reportedErrors.add((exception: exception, tag: tag));
  }
}
