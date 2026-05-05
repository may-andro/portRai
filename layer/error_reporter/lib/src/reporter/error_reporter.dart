import 'package:core/core.dart';

abstract class ErrorReporter {
  Future<void> init();

  Future<void> reportError<T extends AppException>({
    required T exception,
    required StackTrace stackTrace,
    String? tag,
  });

  void Function(Object, StackTrace) get globalErrorHandler;
}
