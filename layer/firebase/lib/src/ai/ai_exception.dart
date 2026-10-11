import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

sealed class AiException implements AppException {
  const AiException(this.message, this.cause, this.stackTrace);

  final String message;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'AiException: $message';
}

class AiConfigurationException extends AiException {
  const AiConfigurationException(Object cause, StackTrace stackTrace)
    : super('Firebase AI configuration is invalid', cause, stackTrace);
}

class AiQuotaExceededException extends AiException {
  const AiQuotaExceededException(Object cause, StackTrace stackTrace)
    : super('Firebase AI quota exceeded', cause, stackTrace);
}

class AiUnsupportedLocationException extends AiException {
  const AiUnsupportedLocationException(Object cause, StackTrace stackTrace)
    : super('Firebase AI is unavailable in this location', cause, stackTrace);
}

class AiServerException extends AiException {
  const AiServerException(Object cause, StackTrace stackTrace)
    : super('Firebase AI request failed', cause, stackTrace);
}

class AiSdkException extends AiException {
  const AiSdkException(Object cause, StackTrace stackTrace)
    : super(
        'Firebase AI SDK could not process the response',
        cause,
        stackTrace,
      );
}

class AiNetworkException extends AiException {
  const AiNetworkException(Object cause, StackTrace stackTrace)
    : super('Firebase AI network request failed', cause, stackTrace);
}

class AiTimeoutException extends AiException {
  const AiTimeoutException(Object cause, StackTrace stackTrace)
    : super('Firebase AI request timed out', cause, stackTrace);
}

class AiInvalidInputException extends AiException {
  const AiInvalidInputException(Object cause, StackTrace stackTrace)
    : super('Firebase AI input is invalid', cause, stackTrace);
}

class AiBlockedResponseException extends AiException {
  const AiBlockedResponseException(Object cause, StackTrace stackTrace)
    : super('Firebase AI response was blocked', cause, stackTrace);
}

class AiEmptyResponseException extends AiException {
  const AiEmptyResponseException(Object cause, StackTrace stackTrace)
    : super('Firebase AI returned no text', cause, stackTrace);
}

class AiIncompleteResponseException extends AiException {
  const AiIncompleteResponseException(Object cause, StackTrace stackTrace)
    : super(
        'Firebase AI response did not complete normally',
        cause,
        stackTrace,
      );
}

AiException handleAiException(Object error, StackTrace stackTrace) =>
    switch (error) {
      AiException() => error,
      InvalidApiKey() ||
      ServiceApiNotEnabled() => AiConfigurationException(error, stackTrace),
      QuotaExceeded() => AiQuotaExceededException(error, stackTrace),
      UnsupportedUserLocation() => AiUnsupportedLocationException(
        error,
        stackTrace,
      ),
      FirebaseAISdkException() => AiSdkException(error, stackTrace),
      ClientException() => AiNetworkException(error, stackTrace),
      TimeoutException() => AiTimeoutException(error, stackTrace),
      _ => AiServerException(error, stackTrace),
    };
