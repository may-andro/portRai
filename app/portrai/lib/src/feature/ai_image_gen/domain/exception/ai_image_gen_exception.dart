import 'package:core/core.dart';

sealed class AiImageGenException implements AppException {
  const AiImageGenException({this.cause});

  final Object? cause;

  @override
  String toString() {
    var result = 'AiImageGenException';
    if (cause != null) result += ' | Cause: $cause';
    return result;
  }
}

class AiImageUnavailableException extends AiImageGenException {
  const AiImageUnavailableException({super.cause});
}

class AiImageFeatureDisabledException extends AiImageGenException {
  const AiImageFeatureDisabledException({super.cause});
}

class AiImageSourceException extends AiImageGenException {
  const AiImageSourceException({super.cause});
}

class AiImageGenerationException extends AiImageGenException {
  const AiImageGenerationException({super.cause});
}

class AiImageCacheException extends AiImageGenException {
  const AiImageCacheException({super.cause});
}

class AiImageProcessingException extends AiImageGenException {
  const AiImageProcessingException({super.cause});
}
