import 'package:core/core.dart';

sealed class ProjectException implements AppException {
  const ProjectException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ProjectException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class ProjectNotFoundException extends ProjectException {
  const ProjectNotFoundException({super.cause, super.stackTrace});
}

class ProjectNetworkException extends ProjectException {
  const ProjectNetworkException({super.cause, super.stackTrace});
}

class ProjectParsingException extends ProjectException {
  const ProjectParsingException({super.cause, super.stackTrace});
}

class ProjectUnauthorizedException extends ProjectException {
  const ProjectUnauthorizedException({super.cause, super.stackTrace});
}

class ProjectCacheException extends ProjectException {
  const ProjectCacheException({super.cause, super.stackTrace});
}
