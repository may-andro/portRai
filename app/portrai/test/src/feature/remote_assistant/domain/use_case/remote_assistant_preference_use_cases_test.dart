import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/get_remote_assistant_preference_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/reset_remote_assistant_session_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/update_remote_assistant_preference_use_case.dart';

import '../../../../../mock/feature/remote_assistant/domain/repository/mock_remote_assistant_repository.dart';

void main() {
  setUp(() {
    registerFallbackValue(
      const RemoteAssistantPreferenceEntity(
        enabled: false,
        consentAccepted: false,
      ),
    );
  });

  test(
    'should return the stored preference when loading preferences',
    () async {
      const preference = RemoteAssistantPreferenceEntity(
        enabled: true,
        consentAccepted: true,
      );
      final repository = MockRemoteAssistantRepository()
        ..stubGetPreference(preference);

      final result = await GetRemoteAssistantPreferenceUseCase(repository)();

      expect(result.isRight, isTrue);
      expect(result.right, preference);
    },
  );

  test(
    'should preserve preference persistence failures when reading',
    () async {
      final repository = MockRemoteAssistantRepository()
        ..stubGetPreferenceError(const RemoteAssistantPreferenceFailure());

      final result = await GetRemoteAssistantPreferenceUseCase(repository)();

      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantPreferenceFailure>());
    },
  );

  test('should update preferences when a new choice is submitted', () async {
    const preference = RemoteAssistantPreferenceEntity(
      enabled: true,
      consentAccepted: true,
    );
    final repository = MockRemoteAssistantRepository()
      ..stubUpdatePreference(preference);

    final result = await UpdateRemoteAssistantPreferenceUseCase(repository)(
      preference,
    );

    expect(result.isRight, isTrue);
  });

  test(
    'should preserve preference failures when updating preferences',
    () async {
      final repository = MockRemoteAssistantRepository()
        ..stubUpdatePreferenceError(const RemoteAssistantPreferenceFailure());

      final result = await UpdateRemoteAssistantPreferenceUseCase(repository)(
        const RemoteAssistantPreferenceEntity(
          enabled: true,
          consentAccepted: true,
        ),
      );

      expect(result.isLeft, isTrue);
      expect(result.left, isA<RemoteAssistantPreferenceFailure>());
    },
  );

  test('should reset the model session when requested', () async {
    final repository = MockRemoteAssistantRepository()..stubResetSession();

    final result = await ResetRemoteAssistantSessionUseCase(repository)();

    expect(result.isRight, isTrue);
    verify(() => repository.resetSession()).called(1);
  });

  test('should return an unknown failure when session reset fails', () async {
    final repository = MockRemoteAssistantRepository()
      ..stubResetSessionError(StateError('reset failed'));

    final result = await ResetRemoteAssistantSessionUseCase(repository)();

    expect(result.isLeft, isTrue);
    expect(result.left, isA<RemoteAssistantUnknownFailure>());
  });
}
