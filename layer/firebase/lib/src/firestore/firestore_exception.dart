import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

// Base Firestore exception
sealed class FirestoreException implements AppException {
  const FirestoreException(this.message, this.cause, this.stackTrace);

  final String message;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'FirestoreException: $message';
}

// Specific exception types
class FirestoreDocumentNotFoundException extends FirestoreException {
  const FirestoreDocumentNotFoundException(
    String documentPath,
    Object cause,
    StackTrace stackTrace,
  ) : super('Document not found: $documentPath', cause, stackTrace);
}

class FirestoreCollectionNotFoundException extends FirestoreException {
  const FirestoreCollectionNotFoundException(
    String collectionPath,
    Object cause,
    StackTrace stackTrace,
  ) : super('Collection not found: $collectionPath', cause, stackTrace);
}

class FirestorePermissionDeniedException extends FirestoreException {
  const FirestorePermissionDeniedException(
    String operation,
    Object cause,
    StackTrace stackTrace,
  ) : super('Permission denied for operation: $operation', cause, stackTrace);
}

class FirestoreNetworkException extends FirestoreException {
  const FirestoreNetworkException(Object cause, StackTrace stackTrace)
    : super('Network error occurred', cause, stackTrace);
}

class FirestoreTimeoutException extends FirestoreException {
  const FirestoreTimeoutException(
    String operation,
    Object cause,
    StackTrace stackTrace,
  ) : super('Operation timed out: $operation', cause, stackTrace);
}

class FirestoreInvalidDataException extends FirestoreException {
  const FirestoreInvalidDataException(
    String field,
    Object cause,
    StackTrace stackTrace,
  ) : super('Invalid data for field: $field', cause, stackTrace);
}

class FirestoreQuotaExceededException extends FirestoreException {
  const FirestoreQuotaExceededException(Object cause, StackTrace stackTrace)
    : super('Firestore quota exceeded', cause, stackTrace);
}

class FirestoreUnknownException extends FirestoreException {
  const FirestoreUnknownException(Object cause, StackTrace stackTrace)
    : super('Unknown Firestore error occurred', cause, stackTrace);
}

/// Helper method to handle Firestore exceptions consistently
FirestoreException handleFirestoreException(
  Object error,
  StackTrace stackTrace,
  String operation,
) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'not-found':
        return FirestoreDocumentNotFoundException(operation, error, stackTrace);
      case 'permission-denied':
        return FirestorePermissionDeniedException(operation, error, stackTrace);
      case 'unavailable':
      case 'deadline-exceeded':
        return FirestoreTimeoutException(operation, error, stackTrace);
      case 'invalid-argument':
      case 'failed-precondition':
        return FirestoreInvalidDataException(operation, error, stackTrace);
      case 'resource-exhausted':
        return FirestoreQuotaExceededException(error, stackTrace);
      case 'unauthenticated':
        return FirestorePermissionDeniedException(
          'Authentication required for $operation',
          error,
          stackTrace,
        );
      default:
        return FirestoreUnknownException(error, stackTrace);
    }
  }

  // Handle network-related exceptions
  if (error.toString().contains('network') ||
      error.toString().contains('connection')) {
    return FirestoreNetworkException(error, stackTrace);
  }

  return FirestoreUnknownException(error, stackTrace);
}
