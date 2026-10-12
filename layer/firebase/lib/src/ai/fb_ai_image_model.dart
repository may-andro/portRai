import 'dart:async';
import 'dart:typed_data';

import 'package:firebase/src/ai/ai_exception.dart';
import 'package:firebase/src/ai/ai_model_client.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

class FbAiImage {
  const FbAiImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

/// A stateless image model. The caller owns consent, caching and cost limits.
class FbAiImageModel {
  FbAiImageModel(this._model);

  final AiModelClient _model;
  var _closed = false;

  /// Closes this model's transport. Pending requests are not cancelled on the
  /// backend.
  void close() {
    if (_closed) return;
    _closed = true;
    _model.close();
  }

  Future<FbAiImage> generateImage(Iterable<Content> contents) async {
    if (_closed) {
      throw StateError('The Firebase AI image model is closed.');
    }
    final prompt = List<Content>.of(contents);
    if (prompt.isEmpty || prompt.every((content) => content.parts.isEmpty)) {
      throw AiInvalidInputException(
        ArgumentError('At least one non-empty content item is required.'),
        StackTrace.current,
      );
    }

    final GenerateContentResponse response;
    try {
      response = await _model.generateContent(prompt);
    } on FirebaseAIException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on FirebaseAISdkException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on ClientException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    } on TimeoutException catch (error, stackTrace) {
      throw handleAiException(error, stackTrace);
    }

    if (response.promptFeedback?.blockReason != null ||
        (response.candidates.isEmpty && response.promptFeedback != null)) {
      throw AiBlockedResponseException(response, StackTrace.current);
    }
    final reason = response.candidates.firstOrNull?.finishReason;
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
      case null || FinishReason.stop:
        break;
      default:
        throw AiIncompleteResponseException(
          response,
          StackTrace.current,
          finishReason: reason.name,
        );
    }

    final image = response.inlineDataParts
        .where((part) => part.mimeType.startsWith('image/'))
        .firstOrNull;
    if (image == null || image.bytes.isEmpty) {
      throw AiEmptyResponseException(
        StateError('No image data was returned.'),
        StackTrace.current,
      );
    }
    return FbAiImage(bytes: image.bytes, mimeType: image.mimeType);
  }
}
