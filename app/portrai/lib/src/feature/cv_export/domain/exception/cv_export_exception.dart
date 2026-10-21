class CvPdfGenerationException implements Exception {
  const CvPdfGenerationException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'CvPdfGenerationException: $message';
}

class CvPdfShareException implements Exception {
  const CvPdfShareException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'CvPdfShareException: $message';
}

/// The tailoring response could not be read.
class CvTailoringResponseException implements Exception {
  const CvTailoringResponseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'CvTailoringResponseException: $message';
}
