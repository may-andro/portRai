import 'dart:async';

import 'package:firebase/src/ai/ai_exception.dart';
import 'package:firebase/src/ai/ai_model_client.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

/// A stateless text model. The caller owns conversation history and consent.
class FbAiTextModel {
  FbAiTextModel(this._model);

  final AiModelClient _model;
  var _closed = false;

  /// Closes this model's transport. The owning feature must stop its subscriptions
  /// before disposal and invalidate pending responses.
  void close() {
    if (_closed) return;
    _closed = true;
    _model.close();
  }

  Future<String> generateText(Iterable<Content> contents) =>
      _generate(contents, streaming: false).join();

  /// Emits text deltas, not accumulated answers. Only normal stream completion
  /// commits an answer; discard partial text on error. Cancellation stops local
  /// consumption but does not guarantee cancellation of backend generation.
  Stream<String> generateTextStream(Iterable<Content> contents) =>
      _generate(contents, streaming: true);

  Stream<String> _generate(
    Iterable<Content> contents, {
    required bool streaming,
  }) async* {
    if (_closed) {
      throw StateError('The Firebase AI text model is closed.');
    }
    final prompt = List<Content>.of(contents);
    if (prompt.isEmpty || prompt.every((content) => content.parts.isEmpty)) {
      throw AiInvalidInputException(
        ArgumentError('At least one non-empty content item is required.'),
        StackTrace.current,
      );
    }

    var hasText = false;
    var completed = false;
    try {
      final responses = streaming
          ? _model.generateContentStream(prompt)
          : _model.generateContent(prompt).asStream();
      await for (final response in responses) {
        if (response.promptFeedback?.blockReason != null ||
            (response.candidates.isEmpty && response.promptFeedback != null)) {
          throw AiBlockedResponseException(response, StackTrace.current);
        }
        if (response.candidates.isEmpty) continue;
        final reason = response.candidates.first.finishReason;
        switch (reason) {
          case FinishReason.safety ||
              FinishReason.recitation ||
              FinishReason.blocklist ||
              FinishReason.prohibitedContent ||
              FinishReason.spii ||
              FinishReason.imageSafety ||
              FinishReason.imageProhibitedContent ||
              FinishReason.imageRecitation:
            throw AiBlockedResponseException(response, StackTrace.current);
          case null:
            break;
          case FinishReason.stop:
            completed = true;
          default:
            throw AiIncompleteResponseException(response, StackTrace.current);
        }
        final text = response.text;
        if (text == null || text.isEmpty) continue;
        if (text.trim().isNotEmpty) hasText = true;
        yield text;
      }
    } on FirebaseAIException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on FirebaseAISdkException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on ClientException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on TimeoutException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    }
    if (!hasText) {
      throw AiEmptyResponseException(
        StateError('No non-whitespace text was returned.'),
        StackTrace.current,
      );
    }
    if (!completed) {
      throw AiIncompleteResponseException(
        StateError('The response ended without a normal finish reason.'),
        StackTrace.current,
      );
    }
  }
}
