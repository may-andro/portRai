import 'package:core/core.dart';

class HandlerRegisteredException implements AppException {
  @override
  String toString() {
    return 'HandlerRegisteredException: The handler is already registered';
  }
}
