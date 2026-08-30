import 'package:feature_flag/src/data/data_source/remote_feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock/mock_fb_remote_config_controller.dart';

void main() {
  group('RemoteFeatureFlagDataSource', () {
    late RemoteFeatureFlagDataSource dataSource;
    late MockFbRemoteConfigController mockController;

    setUp(() {
      mockController = MockFbRemoteConfigController();
      dataSource = RemoteFeatureFlagDataSource(mockController);
    });

    group('resolveFeatureFlags', () {
      test('should return empty list when definitions is empty', () {
        when(() => mockController.getAllConfigsValue()).thenReturn({});

        final result = dataSource.resolveFeatureFlags(const []);

        expect(result, isEmpty);
      });

      test('should fall back to definition default value when key is not '
          'found remotely', () {
        when(() => mockController.getAllConfigsValue()).thenReturn({});

        final result = dataSource.resolveFeatureFlags(const [
          FeatureFlagDefinition(key: 'local_feature', defaultValue: true),
        ]);

        expect(
          result,
          equals(const [FeatureFlag(key: 'local_feature', isEnabled: true)]),
        );
      });

      test('should resolve to remote value with hasRemoteSource true when key '
          'is found remotely', () {
        final mockValue = MockRemoteConfigValue();
        when(() => mockValue.asBool()).thenReturn(true);
        when(
          () => mockController.getAllConfigsValue(),
        ).thenReturn({'feature_login': mockValue});

        final result = dataSource.resolveFeatureFlags(const [
          FeatureFlagDefinition(key: 'feature_login', defaultValue: false),
        ]);

        expect(
          result,
          equals(const [
            FeatureFlag(
              key: 'feature_login',
              isEnabled: true,
              hasRemoteSource: true,
              remoteValue: true,
            ),
          ]),
        );
      });

      test('should resolve each definition independently when definitions mix '
          'remote and local-only keys', () {
        final mockValue = MockRemoteConfigValue();
        when(() => mockValue.asBool()).thenReturn(false);
        when(
          () => mockController.getAllConfigsValue(),
        ).thenReturn({'feature_remote': mockValue});

        final result = dataSource.resolveFeatureFlags(const [
          FeatureFlagDefinition(key: 'feature_remote', defaultValue: true),
          FeatureFlagDefinition(key: 'feature_local', defaultValue: true),
        ]);

        expect(
          result,
          equals(const [
            FeatureFlag(
              key: 'feature_remote',
              isEnabled: false,
              hasRemoteSource: true,
              remoteValue: false,
            ),
            FeatureFlag(key: 'feature_local', isEnabled: true),
          ]),
        );
      });
    });

    group('updateFeatureFlag', () {
      test('should return null when called', () {
        const featureFlag = FeatureFlag(key: 'test_feature', isEnabled: true);

        final result = dataSource.updateFeatureFlag(featureFlag);

        expect(result, isNull);
      });
    });

    group('reset', () {
      test('should return null when called', () {
        final result = dataSource.reset();

        expect(result, isNull);
      });
    });
  });
}
