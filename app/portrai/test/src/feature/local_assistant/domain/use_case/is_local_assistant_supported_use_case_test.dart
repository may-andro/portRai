import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant_availability.dart';
import 'package:use_case/use_case.dart';

void main() {
  for (final supported in [false, true]) {
    test('should return platform support when supported=$supported', () {
      final result = IsLocalAssistantSupportedUseCase(
        LocalAssistantAvailability.supported(supported),
      )();
      expect(result, isA<Either<NoFailure, bool>>());
      expect((result as Either<NoFailure, bool>).right, supported);
    });
  }
}
