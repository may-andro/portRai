import 'dart:async';

import 'package:firebase/src/remote_config/fb_remote_config_controller.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/remote_config/mock_firebase_remote_config.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      RemoteConfigSettings(
        fetchTimeout: Duration.zero,
        minimumFetchInterval: Duration.zero,
      ),
    );
  });

  group(FbRemoteConfigController, () {
    late MockFirebaseRemoteConfig remoteConfig;
    late FbRemoteConfigController controller;

    setUp(() {
      remoteConfig = MockFirebaseRemoteConfig();
      controller = FbRemoteConfigController(remoteConfig);
    });

    test('should limit how long a fetch may take', () async {
      remoteConfig.stubSetUp(
        lastFetchStatus: RemoteConfigFetchStatus.noFetchYet,
      );

      await controller.initialiseRemoteConfig(defaultConfigsMap: const {});

      final settings =
          verify(
                () => remoteConfig.setConfigSettings(captureAny()),
              ).captured.single
              as RemoteConfigSettings;
      expect(settings.fetchTimeout, const Duration(seconds: 5));
      expect(settings.minimumFetchInterval, const Duration(hours: 12));
    });

    test('should wait for the first fetch when nothing was fetched', () async {
      remoteConfig.stubSetUp(
        lastFetchStatus: RemoteConfigFetchStatus.noFetchYet,
      );

      await controller.initialiseRemoteConfig(defaultConfigsMap: const {});

      verify(() => remoteConfig.fetchAndActivate()).called(1);
      verifyNever(() => remoteConfig.activate());
      verifyNever(() => remoteConfig.fetch());
    });

    test(
      'should activate earlier values without waiting for a new fetch',
      () async {
        final fetchCompleter = Completer<void>();
        remoteConfig
          ..stubSetUp(lastFetchStatus: RemoteConfigFetchStatus.success)
          ..stubFetch(() => fetchCompleter.future);

        await controller.initialiseRemoteConfig(defaultConfigsMap: const {});

        verify(() => remoteConfig.activate()).called(1);
        verify(() => remoteConfig.fetch()).called(1);
        verifyNever(() => remoteConfig.fetchAndActivate());
        expect(fetchCompleter.isCompleted, isFalse);
      },
    );

    test('should ignore a failed background fetch', () async {
      remoteConfig
        ..stubSetUp(lastFetchStatus: RemoteConfigFetchStatus.failure)
        ..stubFetch(() async => throw Exception('offline'));

      await controller.initialiseRemoteConfig(defaultConfigsMap: const {});
      await Future<void>.delayed(Duration.zero);

      verify(() => remoteConfig.activate()).called(1);
    });
  });
}
