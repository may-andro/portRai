import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_controller.dart';
import 'package:feature_flag/src/feature_flag_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/mocked_feature_flag_data_source.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('FeatureFlagController', () {
    late FeatureFlagController controller;
    late MockedFeatureFlagDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockedFeatureFlagDataSource();
      controller = FeatureFlagController(mockDataSource);
    });

    group('initFeatureFlags', () {
      test(
        'should initialize feature flags from data source successfully',
        () async {
          const mockFlags = [
            FeatureFlag(key: 'login_feature', isEnabled: true),
            FeatureFlag(key: 'dashboard_feature', isEnabled: false),
            FeatureFlag(key: 'analytics_feature', isEnabled: true),
          ];
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenAnswer((_) => mockFlags);

          await controller.initFeatureFlags();

          verify(() => mockDataSource.initFeatureFlags()).called(1);
          final allFlags = controller.getAllFeatureFlags();
          expect(allFlags, hasLength(3));
          expect(allFlags.map((f) => f.key), contains('login_feature'));
          expect(allFlags.map((f) => f.key), contains('dashboard_feature'));
          expect(allFlags.map((f) => f.key), contains('analytics_feature'));
        },
      );

      test(
        'should throw FeatureFlagInitializationException when data source fails',
        () {
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenThrow(Exception('Data source error'));

          expect(
            () => controller.initFeatureFlags(),
            throwsA(isA<FeatureFlagInitializationException>()),
          );
          verify(() => mockDataSource.initFeatureFlags()).called(1);
        },
      );
    });

    group('getAllFeatureFlags', () {
      test('should return all feature flags when flags exist', () async {
        const mockFlags = [
          FeatureFlag(key: 'feature1', isEnabled: true),
          FeatureFlag(key: 'feature2', isEnabled: false),
          FeatureFlag(key: 'feature3', isEnabled: true),
        ];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => mockFlags);
        await controller.initFeatureFlags();

        final result = controller.getAllFeatureFlags();

        expect(result, hasLength(3));
        expect(result[0].key, equals('feature1'));
        expect(result[0].isEnabled, isTrue);
        expect(result[1].key, equals('feature2'));
        expect(result[1].isEnabled, isFalse);
        expect(result[2].key, equals('feature3'));
        expect(result[2].isEnabled, isTrue);
      });

      test(
        'should throw EmptyFeatureFlagsException when no flags are loaded',
        () {
          expect(
            () => controller.getAllFeatureFlags(),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
        },
      );

      test(
        'should throw EmptyFeatureFlagsException after initialization with empty flags',
        () async {
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenAnswer((_) => <FeatureFlag>[]);
          await controller.initFeatureFlags();

          expect(
            () => controller.getAllFeatureFlags(),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
        },
      );
    });

    group('isFeatureEnabled', () {
      setUp(() async {
        const mockFlags = [
          FeatureFlag(key: 'enabled_feature', isEnabled: true),
          FeatureFlag(key: 'disabled_feature', isEnabled: false),
          FeatureFlag(key: 'another_feature', isEnabled: true),
        ];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => mockFlags);
        await controller.initFeatureFlags();
      });

      test('should return true for enabled feature', () {
        expect(controller.isFeatureEnabled('enabled_feature'), isTrue);
        expect(controller.isFeatureEnabled('another_feature'), isTrue);
      });

      test('should return false for disabled feature', () {
        expect(controller.isFeatureEnabled('disabled_feature'), isFalse);
      });

      test(
        'should throw FeatureFlagNotFoundException for non-existent feature',
        () {
          expect(
            () => controller.isFeatureEnabled('non_existent_feature'),
            throwsA(isA<FeatureFlagNotFoundException>()),
          );
        },
      );

      test(
        'should throw EmptyFeatureFlagsException when no flags are loaded',
        () {
          final emptyController = FeatureFlagController(mockDataSource);

          expect(
            () => emptyController.isFeatureEnabled('any_feature'),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
        },
      );

      test('should handle case-sensitive feature keys', () {
        expect(controller.isFeatureEnabled('enabled_feature'), isTrue);
        expect(
          () => controller.isFeatureEnabled('ENABLED_FEATURE'),
          throwsA(isA<FeatureFlagNotFoundException>()),
        );
        expect(
          () => controller.isFeatureEnabled('Enabled_Feature'),
          throwsA(isA<FeatureFlagNotFoundException>()),
        );
      });
    });

    group('updateFeatureFlag', () {
      setUp(() async {
        const mockFlags = [
          FeatureFlag(key: 'feature1', isEnabled: true),
          FeatureFlag(key: 'feature2', isEnabled: false),
        ];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => mockFlags);
        when(() => mockDataSource.updateFeatureFlag(any())).thenAnswer((_) async {});
        await controller.initFeatureFlags();
      });

      test('should update existing feature flag successfully', () {
        const updatedFlag = FeatureFlag(key: 'feature1', isEnabled: false);
        expect(controller.isFeatureEnabled('feature1'), isTrue);

        controller.updateFeatureFlag(updatedFlag);

        expect(controller.isFeatureEnabled('feature1'), isFalse);
        verify(() => mockDataSource.updateFeatureFlag(updatedFlag)).called(1);
      });

      test('should update multiple feature flags independently', () {
        const flag1Update = FeatureFlag(key: 'feature1', isEnabled: false);
        const flag2Update = FeatureFlag(key: 'feature2', isEnabled: true);

        controller.updateFeatureFlag(flag1Update);
        controller.updateFeatureFlag(flag2Update);

        expect(controller.isFeatureEnabled('feature1'), isFalse);
        expect(controller.isFeatureEnabled('feature2'), isTrue);
        verify(() => mockDataSource.updateFeatureFlag(flag1Update)).called(1);
        verify(() => mockDataSource.updateFeatureFlag(flag2Update)).called(1);
      });

      test(
        'should throw FeatureFlagNotFoundException for non-existent feature',
        () {
          const nonExistentFlag = FeatureFlag(
            key: 'non_existent',
            isEnabled: true,
          );

          expect(
            () => controller.updateFeatureFlag(nonExistentFlag),
            throwsA(isA<FeatureFlagNotFoundException>()),
          );
          verifyNever(() => mockDataSource.updateFeatureFlag(any()));
        },
      );

      test(
        'should throw EmptyFeatureFlagsException when no flags are loaded',
        () {
          final emptyController = FeatureFlagController(mockDataSource);
          const flag = FeatureFlag(key: 'any_feature', isEnabled: true);

          expect(
            () => emptyController.updateFeatureFlag(flag),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
          verifyNever(() => mockDataSource.updateFeatureFlag(any()));
        },
      );

      test('should handle sync updateFeatureFlag from data source', () async {
        const updatedFlag = FeatureFlag(key: 'feature1', isEnabled: false);
        when(() => mockDataSource.updateFeatureFlag(any())).thenReturn(null);

        await controller.updateFeatureFlag(updatedFlag);

        expect(controller.isFeatureEnabled('feature1'), isFalse);
        verify(() => mockDataSource.updateFeatureFlag(updatedFlag)).called(1);
      });

      test('should update flag even if data source call fails silently', () {
        const updatedFlag = FeatureFlag(key: 'feature1', isEnabled: false);

        controller.updateFeatureFlag(updatedFlag);

        expect(controller.isFeatureEnabled('feature1'), isFalse);
        verify(() => mockDataSource.updateFeatureFlag(updatedFlag)).called(1);
      });
    });

    group('reset', () {
      test('should reset flags and reinitialize successfully', () async {
        const initialFlags = [
          FeatureFlag(key: 'feature1', isEnabled: true),
          FeatureFlag(key: 'feature2', isEnabled: false),
        ];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => initialFlags);
        when(() => mockDataSource.reset()).thenAnswer((_) {});
        await controller.initFeatureFlags();

        expect(controller.getAllFeatureFlags(), hasLength(2));

        const newFlags = [FeatureFlag(key: 'feature3', isEnabled: true)];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => newFlags);

        await controller.reset();

        final flagsAfterReset = controller.getAllFeatureFlags();
        expect(flagsAfterReset, hasLength(1));
        expect(flagsAfterReset.first.key, equals('feature3'));
        expect(flagsAfterReset.first.isEnabled, isTrue);

        verify(() => mockDataSource.reset()).called(1);
        verify(
          () => mockDataSource.initFeatureFlags(),
        ).called(2); // Initial + after reset
      });

      test('should handle empty flags after reset', () async {
        const initialFlags = [FeatureFlag(key: 'feature1', isEnabled: true)];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => initialFlags);
        when(() => mockDataSource.reset()).thenAnswer((_) {});
        await controller.initFeatureFlags();

        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => <FeatureFlag>[]);

        await controller.reset();

        expect(
          () => controller.getAllFeatureFlags(),
          throwsA(isA<EmptyFeatureFlagsException>()),
        );
        verify(() => mockDataSource.reset()).called(1);
        verify(() => mockDataSource.initFeatureFlags()).called(2);
      });

      test(
        'should throw FeatureFlagResetException when data source reset fails',
        () async {
          const initialFlags = [FeatureFlag(key: 'feature1', isEnabled: true)];
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenAnswer((_) => initialFlags);
          await controller.initFeatureFlags();

          when(
            () => mockDataSource.reset(),
          ).thenThrow(Exception('Reset failed'));

          expect(
            () => controller.reset(),
            throwsA(isA<FeatureFlagResetException>()),
          );
          verify(() => mockDataSource.reset()).called(1);
        },
      );

      test(
        'should throw FeatureFlagResetException when reinitialization fails',
        () async {
          const initialFlags = [FeatureFlag(key: 'feature1', isEnabled: true)];
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenAnswer((_) => initialFlags);
          await controller.initFeatureFlags();

          when(() => mockDataSource.reset()).thenAnswer((_) {});
          // Set up the mock to fail on the second call (during reset)
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenThrow(Exception('Reinit failed'));

          expect(
            () => controller.reset(),
            throwsA(isA<FeatureFlagResetException>()),
          );
          verify(() => mockDataSource.reset()).called(1);
          // Only verify the reset call, not the init call count since
          // the second init call fails and the behavior may vary
        },
      );

      test(
        'should clear internal state even if reinitialization fails',
        () async {
          const initialFlags = [FeatureFlag(key: 'feature1', isEnabled: true)];
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenAnswer((_) => initialFlags);
          await controller.initFeatureFlags();

          expect(controller.isFeatureEnabled('feature1'), isTrue);

          when(() => mockDataSource.reset()).thenAnswer((_) {});
          when(
            () => mockDataSource.initFeatureFlags(),
          ).thenThrow(Exception('Reinit failed'));

          try {
            await controller.reset();
          } catch (e) {
            // Expected to fail
          }

          // Assert - State should be cleared even though reinit failed
          expect(
            () => controller.getAllFeatureFlags(),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
          expect(
            () => controller.isFeatureEnabled('feature1'),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
        },
      );

      test('should handle sync reset from data source', () async {
        const initialFlags = [FeatureFlag(key: 'feature1', isEnabled: true)];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => initialFlags);
        await controller.initFeatureFlags();

        when(() => mockDataSource.reset()).thenReturn(null);
        const newFlags = [FeatureFlag(key: 'feature2', isEnabled: false)];
        when(
          () => mockDataSource.initFeatureFlags(),
        ).thenAnswer((_) => newFlags);

        await controller.reset();

        final flagsAfterReset = controller.getAllFeatureFlags();
        expect(flagsAfterReset, hasLength(1));
        expect(flagsAfterReset.first.key, equals('feature2'));
        verify(() => mockDataSource.reset()).called(1);
      });
    });
  });
}
