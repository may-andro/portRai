import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/reset_remote_assistant_session_use_case.dart';

import '../../../../../mock/feature/remote_assistant/domain/repository/mock_remote_assistant_repository.dart';

void main() {
  test('should reset the session when called', () async {
    final repository = MockRemoteAssistantRepository()..stubResetSession();

    final resetRemoteAssistantSessionEither =
        await ResetRemoteAssistantSessionUseCase(repository)();

    expect(resetRemoteAssistantSessionEither.isRight, isTrue);
  });

  test(
    'should keep the sanitized cause when a Firebase AI error makes reset fail',
    () async {
      const error = AiSdkException('secret server body', StackTrace.empty);
      final repository = MockRemoteAssistantRepository()
        ..stubResetSessionError(error);

      final resetRemoteAssistantSessionEither =
          await ResetRemoteAssistantSessionUseCase(repository)();

      final failure = resetRemoteAssistantSessionEither.left;
      expect(failure, isA<ResetRemoteAssistantSessionUnknownFailure>());
      expect(failure.cause, same(error));
      expect(failure.toString(), isNot(contains('secret')));
    },
  );

  for (final error in <Object>[
    const RemoteAssistantCancelledException(),
    StateError('secret server body'),
  ]) {
    test(
      'should drop the cause when ${error.runtimeType} makes reset fail',
      () async {
        final repository = MockRemoteAssistantRepository()
          ..stubResetSessionError(error);

        final resetRemoteAssistantSessionEither =
            await ResetRemoteAssistantSessionUseCase(repository)();

        final failure = resetRemoteAssistantSessionEither.left;
        expect(failure, isA<ResetRemoteAssistantSessionUnknownFailure>());
        expect(failure.cause, isNull);
        expect(failure.toString(), isNot(contains('secret')));
      },
    );
  }
}
