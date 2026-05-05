import 'package:logger/logger.dart';

class MockLogger extends Logger {
  MockLogger() : super(printer: PrettyPrinter());
  final List<String> infos = [];
  final List<String> errors = [];

  @override
  void i(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    infos.add(message.toString());
  }

  @override
  void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    errors.add(message.toString());
  }
}
