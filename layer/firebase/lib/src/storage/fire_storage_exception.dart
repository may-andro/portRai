import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';

sealed class FireStorageException implements AppException {
  FireStorageException(this.cause, this.stackTrace);

  final Object cause;
  final StackTrace stackTrace;
}

final class StorageDownloadErrorException extends FireStorageException {
  StorageDownloadErrorException(super.cause, super.stackTrace);
}

final class StorageUploadErrorException extends FireStorageException {
  StorageUploadErrorException(super.cause, super.stackTrace);
}

final class StorageUploadCancelledException extends FireStorageException {
  StorageUploadCancelledException(super.cause, super.stackTrace);
}

final class StorageUploadPausedException extends FireStorageException {
  StorageUploadPausedException(super.cause, super.stackTrace);
}

final class StorageUploadRunningException extends FireStorageException {
  StorageUploadRunningException(super.cause, super.stackTrace);
}

final class StorageUploadFailedException extends FireStorageException {
  StorageUploadFailedException(super.cause, super.stackTrace);
}

final class StorageDeleteErrorException extends FireStorageException {
  StorageDeleteErrorException(super.cause, super.stackTrace);
}

FireStorageException? mapFailureToException(TaskState state) {
  final st = StackTrace.current;
  switch (state) {
    case TaskState.success:
      return null;
    case TaskState.error:
      throw StorageUploadErrorException(state, st);
    case TaskState.canceled:
      throw StorageUploadCancelledException(state, st);
    case TaskState.paused:
      throw StorageUploadPausedException(state, st);
    case TaskState.running:
      throw StorageUploadRunningException(state, st);
  }
}
