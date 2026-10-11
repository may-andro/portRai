import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart';

/// Adapter boundary for the SDK's final model class.
abstract interface class AiModelClient {
  void close();

  Future<GenerateContentResponse> generateContent(Iterable<Content> contents);

  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> contents,
  );
}

class FirebaseAiModelClient implements AiModelClient {
  FirebaseAiModelClient(this._model, this._httpClient);

  final GenerativeModel _model;
  final Client _httpClient;

  @override
  void close() => _httpClient.close();

  @override
  Future<GenerateContentResponse> generateContent(Iterable<Content> contents) =>
      _model.generateContent(contents);

  @override
  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> contents,
  ) => _model.generateContentStream(contents);
}
