import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

void main() {
  test('should compare responses by value when their text matches', () {
    expect(
      const AssistantTextResponseEntity(text: 'Answer'),
      const AssistantTextResponseEntity(text: 'Answer'),
    );
    expect(
      const AssistantTextResponseEntity(text: 'Answer'),
      isNot(const AssistantTextResponseEntity(text: 'Other answer')),
    );
  });

  test('should compare messages by value when content and role match', () {
    expect(
      const AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: 'Hello'),
        isUser: true,
      ),
      const AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: 'Hello'),
        isUser: true,
      ),
    );
    expect(
      const AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: 'Hello'),
        isUser: true,
      ),
      isNot(
        const AssistantMessageEntity(
          content: AssistantTextResponseEntity(text: 'Hello'),
          isUser: false,
        ),
      ),
    );
  });
}
