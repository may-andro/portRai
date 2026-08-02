import 'package:feature_flag/src/data/data_source/cache_feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock/mocked_feature_flag_cache.dart';
import '../../../mock/mocked_feature_flag_data_source.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('CacheFeatureFlagDataSource', () {
    late CacheFeatureFlagDataSource dataSource;
    late MockedFeatureFlagDataSource mockDelegateDataSource;
    late MockedFeatureFlagCache mockCache;

    setUp(() {
      mockDelegateDataSource = MockedFeatureFlagDataSource();
      mockCache = MockedFeatureFlagCache();
      dataSource = CacheFeatureFlagDataSource(
        mockDelegateDataSource,
        mockCache,
      );
    });

    group('initFeatureFlags', () {
      test(
        'should fetch from delegate and cache all flags when cache is empty',
        () async {
          const remoteFlags = [
            FeatureFlag(key: 'feature_login', isEnabled: true),
            FeatureFlag(key: 'feature_dashboard', isEnabled: false),
            FeatureFlag(key: 'feature_analytics', isEnabled: true),
          ];

          when(() => mockCache.getAll()).thenAnswer((_) async => []);
          when(
            () => mockDelegateDataSource.initFeatureFlags(),
          ).thenAnswer((_) => remoteFlags);
          when(() => mockCache.put(any())).thenAnswer((_) async {});

          final result = await dataSource.initFeatureFlags();

          expect(result, equals(remoteFlags));
          verify(() => mockCache.getAll()).called(1);
          verify(() => mockDelegateDataSource.initFeatureFlags()).called(1);
          verify(() => mockCache.put(any())).called(3);
        },
      );

      test(
        'should override remote flags with cached values for matching keys when cache has data',
        () async {
          const cachedFlags = [
            FeatureFlag(key: 'feature_login', isEnabled: false),
            FeatureFlag(key: 'feature_dashboard', isEnabled: true),
          ];
          const remoteFlags = [
            FeatureFlag(key: 'feature_login', isEnabled: true),
            FeatureFlag(key: 'feature_dashboard', isEnabled: false),
            FeatureFlag(key: 'feature_analytics', isEnabled: true),
          ];
          const expectedFlags = [
            FeatureFlag(key: 'feature_login', isEnabled: false), // Overridden by cache
            FeatureFlag(key: 'feature_dashboard', isEnabled: true), // Overridden by cache
            FeatureFlag(key: 'feature_analytics', isEnabled: true), // From remote
          ];

          when(() => mockCache.getAll()).thenAnswer((_) async => cachedFlags);
          when(
            () => mockDelegateDataSource.initFeatureFlags(),
          ).thenAnswer((_) => remoteFlags);
          when(() => mockCache.put(any())).thenAnswer((_) async {});

          final result = await dataSource.initFeatureFlags();

          expect(result, equals(expectedFlags));
          verify(() => mockCache.getAll()).called(1);
          verify(() => mockDelegateDataSource.initFeatureFlags()).called(1);
          // Should cache only the new flag 'feature_analytics'
          verify(() => mockCache.put(any())).called(1);
        },
      );

      test(
        'should cache only new flags not present in cache when cache has data',
        () async {
          // Arrange
          const cachedFlags = [
            FeatureFlag(key: 'existing_feature', isEnabled: true),
          ];
          const remoteFlags = [
            FeatureFlag(key: 'existing_feature', isEnabled: false),
            FeatureFlag(key: 'new_feature', isEnabled: true),
          ];

          when(() => mockCache.getAll()).thenAnswer((_) async => cachedFlags);
          when(
            () => mockDelegateDataSource.initFeatureFlags(),
          ).thenAnswer((_) => remoteFlags);
          when(() => mockCache.put(any())).thenAnswer((_) async {});

          // Act
          await dataSource.initFeatureFlags();

          // Assert
          final captured = verify(() => mockCache.put(captureAny())).captured;
          expect(captured, hasLength(1));
          final newFlag = captured.first as FeatureFlag;
          expect(newFlag.key, equals('new_feature'));
          expect(newFlag.isEnabled, equals(true));
        },
      );

      test(
        'should not cache when all remote flags are already cached',
        () async {
          // Arrange
          const cachedFlags = [
            FeatureFlag(key: 'feature_one', isEnabled: true),
            FeatureFlag(key: 'feature_two', isEnabled: false),
          ];
          const remoteFlags = [
            FeatureFlag(key: 'feature_one', isEnabled: false),
            FeatureFlag(key: 'feature_two', isEnabled: true),
          ];

          when(() => mockCache.getAll()).thenAnswer((_) async => cachedFlags);
          when(
            () => mockDelegateDataSource.initFeatureFlags(),
          ).thenAnswer((_) => remoteFlags);

          // Act
          await dataSource.initFeatureFlags();

          // Assert
          verifyNever(() => mockCache.put(any()));
        },
      );

      test(
        'should preserve cached flags that are not in remote when cache has data',
        () async {
          // Arrange
          const cachedFlags = [
            FeatureFlag(key: 'cached_only', isEnabled: true),
            FeatureFlag(key: 'shared_flag', isEnabled: false),
          ];
          const remoteFlags = [
            FeatureFlag(key: 'shared_flag', isEnabled: true),
            FeatureFlag(key: 'remote_only', isEnabled: false),
          ];
          const expectedFlags = [
            FeatureFlag(key: 'shared_flag', isEnabled: false), // Overridden by cache
            FeatureFlag(key: 'remote_only', isEnabled: false), // From remote
          ];

          when(() => mockCache.getAll()).thenAnswer((_) async => cachedFlags);
          when(
            () => mockDelegateDataSource.initFeatureFlags(),
          ).thenAnswer((_) => remoteFlags);
          when(() => mockCache.put(any())).thenAnswer((_) async {});

          // Act
          final result = await dataSource.initFeatureFlags();

          // Assert
          expect(result, equals(expectedFlags));
          // Should not include cached_only as it's not in remote
          expect(result.any((f) => f.key == 'cached_only'), isFalse);
        },
      );
    });

    group('updateFeatureFlag', () {
      test('should put feature flag in cache', () async {
        const featureFlag = FeatureFlag(key: 'test_feature', isEnabled: true);
        when(() => mockCache.put(any())).thenAnswer((_) async {});

        await dataSource.updateFeatureFlag(featureFlag);

        verify(() => mockCache.put(featureFlag)).called(1);
        verifyZeroInteractions(mockDelegateDataSource);
      });
    });

    group('reset', () {
      test('should delete all cache', () async {
        when(() => mockCache.deleteAll()).thenAnswer((_) async {});

        await dataSource.reset();

        verify(() => mockCache.deleteAll()).called(1);
        verifyZeroInteractions(mockDelegateDataSource);
      });
    });
  });
}
