import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:use_case/use_case.dart';

void main() {
  test(
    'should report support based on Flutter web status when called',
    () async {
      final result = await IsLocalAssistantSupportedUseCase()();

      expect(result, isA<Either<NoFailure, bool>>());
      expect(result.right, !kIsWeb);
    },
  );
}
