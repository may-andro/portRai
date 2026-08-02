import 'package:feature_flag/src/data/data_source/remote_feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock/mocked_fb_remote_config_controller.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('RemoteFeatureFlagDataSource', () {
    late RemoteFeatureFlagDataSource dataSource;
    late MockedFbRemoteConfigController mockController;

    setUp(() {
      mockController = MockedFbRemoteConfigController();
      dataSource = RemoteFeatureFlagDataSource(mockController);
    });

    group('initFeatureFlags', () {
      test('should return empty list when no remote configs are available', () {
        when(() => mockController.getAllConfigsValue()).thenReturn({});

        final result = dataSource.initFeatureFlags();

        expect(result, equals(<FeatureFlag>[]));
        verify(() => mockController.getAllConfigsValue()).called(1);
      });

      test(
        'should return feature flags list when remote configs are available',
        () {
          final mockValue1 = MockedRemoteConfigValue();
          final mockValue2 = MockedRemoteConfigValue();
          final mockValue3 = MockedRemoteConfigValue();

          when(() => mockValue1.asBool()).thenReturn(true);
          when(() => mockValue2.asBool()).thenReturn(false);
          when(() => mockValue3.asBool()).thenReturn(true);

          final configValues = <String, RemoteConfigValue>{
            'feature_login': mockValue1,
            'feature_dashboard': mockValue2,
            'feature_analytics': mockValue3,
          };

          when(
            () => mockController.getAllConfigsValue(),
          ).thenReturn(configValues);

          final result = dataSource.initFeatureFlags();

          final expectedList = [
            const FeatureFlag(key: 'feature_login', isEnabled: true),
            const FeatureFlag(key: 'feature_dashboard', isEnabled: false),
            const FeatureFlag(key: 'feature_analytics', isEnabled: true),
          ];
          expect(result, equals(expectedList));
          verify(() => mockController.getAllConfigsValue()).called(1);
          verify(() => mockValue1.asBool()).called(1);
          verify(() => mockValue2.asBool()).called(1);
          verify(() => mockValue3.asBool()).called(1);
        },
      );
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
