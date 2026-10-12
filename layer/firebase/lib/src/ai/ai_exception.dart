import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

sealed class AiException implements AppException {
  const AiException(
    this.message,
    this.cause,
    this.stackTrace, {
    this.serviceMessage,
  });

  final String message;
  final Object cause;
  final StackTrace stackTrace;

  /// Backend error-field details for display, never included in logs.
  /// Only populated from [FirebaseAIException.message], not response bodies.
  final String? serviceMessage;

  @override
  String toString() => 'AiException: $message';
}

class AiConfigurationException extends AiException {
  const AiConfigurationException(
    Object cause,
    StackTrace stackTrace, {
    super.serviceMessage,
  }) : super('Firebase AI configuration is invalid', cause, stackTrace);
}

class AiQuotaExceededException extends AiException {
  const AiQuotaExceededException(
    Object cause,
    StackTrace stackTrace, {
    super.serviceMessage,
  }) : super('Firebase AI quota exceeded', cause, stackTrace);
}

class AiUnsupportedLocationException extends AiException {
  const AiUnsupportedLocationException(
    Object cause,
    StackTrace stackTrace, {
    super.serviceMessage,
  }) : super('Firebase AI is unavailable in this location', cause, stackTrace);
}

class AiServerException extends AiException {
  const AiServerException(
    Object cause,
    StackTrace stackTrace, {
    super.serviceMessage,
  }) : super('Firebase AI request failed', cause, stackTrace);
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
  /// [finishReason] is the provider's reason name only, never generated text.
  const AiIncompleteResponseException(
    Object cause,
    StackTrace stackTrace, {
    String? finishReason,
  }) : super(
         finishReason == null
             ? 'Firebase AI response did not complete normally'
             : 'Firebase AI response did not complete normally '
                   '(finish reason: $finishReason)',
         cause,
         stackTrace,
       );
}

AiException handleAiException(Object error, StackTrace stackTrace) =>
    switch (error) {
      AiException() => error,
      InvalidApiKey(:final message) || ServiceApiNotEnabled(:final message) =>
        AiConfigurationException(error, stackTrace, serviceMessage: message),
      QuotaExceeded() => AiQuotaExceededException(
        error,
        stackTrace,
        serviceMessage: error.message,
      ),
      UnsupportedUserLocation() => AiUnsupportedLocationException(
        error,
        stackTrace,
        serviceMessage: error.message,
      ),
      FirebaseAISdkException() => AiSdkException(error, stackTrace),
      ClientException() => AiNetworkException(error, stackTrace),
      TimeoutException() => AiTimeoutException(error, stackTrace),
      FirebaseAIException() => AiServerException(
        error,
        stackTrace,
        serviceMessage: error.message,
      ),
      _ => AiServerException(error, stackTrace),
    };
