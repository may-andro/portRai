import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_controller.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:feature_flag/src/feature_flag_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/mock_feature_flag_data_source.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('FeatureFlagController', () {
    late FeatureFlagController controller;
    late MockFeatureFlagDataSource mockDataSource;

    const definitions = [
      FeatureFlagDefinition(key: 'login_feature', defaultValue: false),
      FeatureFlagDefinition(key: 'dashboard_feature', defaultValue: false),
      FeatureFlagDefinition(key: 'analytics_feature', defaultValue: false),
    ];

    setUp(() {
      mockDataSource = MockFeatureFlagDataSource();
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
            () => mockDataSource.resolveFeatureFlags(definitions),
          ).thenAnswer((_) async => mockFlags);

          await controller.initFeatureFlags(definitions);

          verify(
            () => mockDataSource.resolveFeatureFlags(definitions),
          ).called(1);
          final allFlags = controller.getAllFeatureFlags();
          expect(allFlags, hasLength(3));
          expect(allFlags.map((f) => f.key), contains('login_feature'));
          expect(allFlags.map((f) => f.key), contains('dashboard_feature'));
          expect(allFlags.map((f) => f.key), contains('analytics_feature'));
        },
      );

      test('should throw FeatureFlagInitializationException when data source '
          'fails', () {
        when(
          () => mockDataSource.resolveFeatureFlags(definitions),
        ).thenThrow(Exception('Data source error'));

        expect(
          () => controller.initFeatureFlags(definitions),
          throwsA(isA<FeatureFlagInitializationException>()),
        );
      });
    });

    group('getAllFeatureFlags', () {
      test('should return all feature flags when flags exist', () async {
        const mockFlags = [
          FeatureFlag(key: 'login_feature', isEnabled: true),
          FeatureFlag(key: 'dashboard_feature', isEnabled: false),
          FeatureFlag(key: 'analytics_feature', isEnabled: true),
        ];
        when(
          () => mockDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => mockFlags);
        await controller.initFeatureFlags(definitions);

        final result = controller.getAllFeatureFlags();

        expect(result, hasLength(3));
        expect(
          result.firstWhere((f) => f.key == 'login_feature').isEnabled,
          isTrue,
        );
        expect(
          result.firstWhere((f) => f.key == 'dashboard_feature').isEnabled,
          isFalse,
        );
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

      test('should throw EmptyFeatureFlagsException after initialization with '
          'empty flags', () async {
        when(
          () => mockDataSource.resolveFeatureFlags(const []),
        ).thenAnswer((_) async => <FeatureFlag>[]);
        await controller.initFeatureFlags(const []);

        expect(
          () => controller.getAllFeatureFlags(),
          throwsA(isA<EmptyFeatureFlagsException>()),
        );
      });
    });

    group('isFeatureEnabled', () {
      setUp(() async {
        const mockFlags = [
          FeatureFlag(key: 'login_feature', isEnabled: true),
          FeatureFlag(key: 'dashboard_feature', isEnabled: false),
          FeatureFlag(key: 'analytics_feature', isEnabled: true),
        ];
        when(
          () => mockDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => mockFlags);
        await controller.initFeatureFlags(definitions);
      });

      test('should return true for enabled feature', () {
        expect(controller.isFeatureEnabled('login_feature'), isTrue);
        expect(controller.isFeatureEnabled('analytics_feature'), isTrue);
      });

      test('should return false for disabled feature', () {
        expect(controller.isFeatureEnabled('dashboard_feature'), isFalse);
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
        expect(controller.isFeatureEnabled('login_feature'), isTrue);
        expect(
          () => controller.isFeatureEnabled('LOGIN_FEATURE'),
          throwsA(isA<FeatureFlagNotFoundException>()),
        );
      });
    });

    group('updateFeatureFlag', () {
      const twoDefinitions = [
        FeatureFlagDefinition(key: 'login_feature', defaultValue: false),
        FeatureFlagDefinition(key: 'dashboard_feature', defaultValue: false),
      ];

      setUp(() async {
        const mockFlags = [
          FeatureFlag(key: 'login_feature', isEnabled: true),
          FeatureFlag(key: 'dashboard_feature', isEnabled: false),
        ];
        when(
          () => mockDataSource.resolveFeatureFlags(twoDefinitions),
        ).thenAnswer((_) async => mockFlags);
        when(
          () => mockDataSource.updateFeatureFlag(any()),
        ).thenAnswer((_) async {});
        await controller.initFeatureFlags(twoDefinitions);
      });

      test('should update existing feature flag successfully', () async {
        const updatedFlag = FeatureFlag(key: 'login_feature', isEnabled: false);
        expect(controller.isFeatureEnabled('login_feature'), isTrue);

        await controller.updateFeatureFlag(updatedFlag);

        expect(controller.isFeatureEnabled('login_feature'), isFalse);
        verify(() => mockDataSource.updateFeatureFlag(updatedFlag)).called(1);
      });

      test('should update multiple feature flags independently', () async {
        const flag1Update = FeatureFlag(key: 'login_feature', isEnabled: false);
        const flag2Update = FeatureFlag(
          key: 'dashboard_feature',
          isEnabled: true,
        );

        await controller.updateFeatureFlag(flag1Update);
        await controller.updateFeatureFlag(flag2Update);

        expect(controller.isFeatureEnabled('login_feature'), isFalse);
        expect(controller.isFeatureEnabled('dashboard_feature'), isTrue);
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
    });

    group('reset', () {
      test('should reset flags and re-resolve using the same definitions '
          'passed to initFeatureFlags', () async {
        const initialFlags = [
          FeatureFlag(key: 'login_feature', isEnabled: true),
          FeatureFlag(key: 'dashboard_feature', isEnabled: false),
          FeatureFlag(key: 'analytics_feature', isEnabled: true),
        ];
        when(
          () => mockDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => initialFlags);
        when(() => mockDataSource.reset()).thenAnswer((_) async {});
        await controller.initFeatureFlags(definitions);

        expect(controller.getAllFeatureFlags(), hasLength(3));

        await controller.reset();

        verify(() => mockDataSource.reset()).called(1);
        // definitions is re-supplied automatically on reset, without the
        // caller passing it again.
        verify(
          () => mockDataSource.resolveFeatureFlags(definitions),
        ).called(2); // initial init + re-resolve after reset
      });

      test('should throw FeatureFlagResetException when data source reset '
          'fails', () async {
        const initialFlags = [
          FeatureFlag(key: 'login_feature', isEnabled: true),
        ];
        when(
          () => mockDataSource.resolveFeatureFlags(const [
            FeatureFlagDefinition(key: 'login_feature', defaultValue: false),
          ]),
        ).thenAnswer((_) async => initialFlags);
        await controller.initFeatureFlags(const [
          FeatureFlagDefinition(key: 'login_feature', defaultValue: false),
        ]);

        when(() => mockDataSource.reset()).thenThrow(Exception('Reset failed'));

        expect(
          () => controller.reset(),
          throwsA(isA<FeatureFlagResetException>()),
        );
      });

      test(
        'should clear internal state even if re-resolving after reset fails',
        () async {
          const singleDefinition = [
            FeatureFlagDefinition(key: 'login_feature', defaultValue: false),
          ];
          const initialFlags = [
            FeatureFlag(key: 'login_feature', isEnabled: true),
          ];
          when(
            () => mockDataSource.resolveFeatureFlags(singleDefinition),
          ).thenAnswer((_) async => initialFlags);
          await controller.initFeatureFlags(singleDefinition);

          expect(controller.isFeatureEnabled('login_feature'), isTrue);

          when(() => mockDataSource.reset()).thenAnswer((_) async {});
          when(
            () => mockDataSource.resolveFeatureFlags(singleDefinition),
          ).thenThrow(Exception('Re-resolve failed'));

          await expectLater(
            controller.reset(),
            throwsA(isA<FeatureFlagResetException>()),
          );

          expect(
            () => controller.getAllFeatureFlags(),
            throwsA(isA<EmptyFeatureFlagsException>()),
          );
        },
      );
    });
  });
}
