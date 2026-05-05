sealed class InjectionException implements Exception {
  InjectionException(this.message, this.cause);

  final String? message;
  final Object? cause;
}

class PreInjectionException extends InjectionException {
  PreInjectionException(super.message, super.cause);
}

class RegisterInjectionException extends InjectionException {
  RegisterInjectionException(super.message, super.cause);
}

class PostInjectionException extends InjectionException {
  PostInjectionException(super.message, super.cause);
}
