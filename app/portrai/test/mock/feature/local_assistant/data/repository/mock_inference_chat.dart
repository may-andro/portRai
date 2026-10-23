import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:mocktail/mocktail.dart';

class MockInferenceChat extends Mock implements InferenceChat {}

extension MockInferenceChatStub on MockInferenceChat {
  /// Stubs the readiness check and every streamed answer to reply [text].
  void stubReply(String text) {
    when(generateChatResponse).thenAnswer((_) async => TextResponse(text));
    stubStreamedAnswer(() => [text]);
  }

  /// Stubs each streamed answer to send the tokens [tokensOf] returns at
  /// that moment, so consecutive answers can differ.
  void stubStreamedAnswer(List<String> Function() tokensOf) {
    when(generateChatResponseAsync).thenAnswer(
      (_) => Stream.fromIterable([
        for (final token in tokensOf()) TextResponse(token),
      ]),
    );
  }
}
