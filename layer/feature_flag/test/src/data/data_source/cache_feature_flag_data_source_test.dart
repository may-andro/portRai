import 'package:feature_flag/src/data/data_source/cache_feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock/mock_feature_flag_cache.dart';
import '../../../mock/mock_feature_flag_data_source.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('CacheFeatureFlagDataSource', () {
    late CacheFeatureFlagDataSource dataSource;
    late MockFeatureFlagDataSource mockDelegateDataSource;
    late MockFeatureFlagCache mockCache;

    setUp(() {
      mockDelegateDataSource = MockFeatureFlagDataSource();
      mockCache = MockFeatureFlagCache();
      dataSource = CacheFeatureFlagDataSource(
        mockDelegateDataSource,
        mockCache,
      );
      when(() => mockCache.put(any())).thenAnswer((_) async {});
    });

    group('resolveFeatureFlags', () {
      const definitions = [
        FeatureFlagDefinition(key: 'feature_login', defaultValue: false),
      ];

      test(
        'should cache and return the delegate value when cache is empty',
        () async {
          const delegateFlags = [
            FeatureFlag(
              key: 'feature_login',
              isEnabled: true,
              hasRemoteSource: true,
              remoteValue: true,
            ),
          ];
          when(() => mockCache.getAll()).thenAnswer((_) async => []);
          when(
            () => mockDelegateDataSource.resolveFeatureFlags(definitions),
          ).thenAnswer((_) async => delegateFlags);

          final result = await dataSource.resolveFeatureFlags(definitions);

          expect(result, equals(delegateFlags));
          verify(() => mockCache.put(delegateFlags.single)).called(1);
        },
      );

      test('should always use the fresh delegate value when the flag has a '
          'remote source, even if a stale value is cached', () async {
        const cachedFlag = FeatureFlag(
          key: 'feature_login',
          isEnabled: false,
          hasRemoteSource: true,
          remoteValue: false,
        );
        const delegateFlag = FeatureFlag(
          key: 'feature_login',
          isEnabled: true,
          hasRemoteSource: true,
          remoteValue: true,
        );
        when(() => mockCache.getAll()).thenAnswer((_) async => [cachedFlag]);
        when(
          () => mockDelegateDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => [delegateFlag]);

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(result, equals([delegateFlag]));
      });

      test('should keep the previously cached value when the flag is '
          'local-only (no remote source)', () async {
        const cachedFlag = FeatureFlag(key: 'feature_login', isEnabled: true);
        const delegateFlag = FeatureFlag(
          key: 'feature_login',
          isEnabled: false,
        );
        when(() => mockCache.getAll()).thenAnswer((_) async => [cachedFlag]);
        when(
          () => mockDelegateDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => [delegateFlag]);

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(result, equals([cachedFlag]));
      });

      test('should use the delegate default-based value when a local-only '
          'flag has never been cached before', () async {
        const delegateFlag = FeatureFlag(
          key: 'feature_login',
          isEnabled: false,
        );
        when(() => mockCache.getAll()).thenAnswer((_) async => []);
        when(
          () => mockDelegateDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => [delegateFlag]);

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(result, equals([delegateFlag]));
      });

      test('should let a developer override win but refresh its remote '
          'metadata from the fresh delegate value', () async {
        const cachedOverride = FeatureFlag(
          key: 'feature_login',
          isEnabled: true,
          isOverridden: true,
          hasRemoteSource: true,
          remoteValue: false,
        );
        const delegateFlag = FeatureFlag(
          key: 'feature_login',
          isEnabled: true,
          hasRemoteSource: true,
          remoteValue: true,
        );
        when(
          () => mockCache.getAll(),
        ).thenAnswer((_) async => [cachedOverride]);
        when(
          () => mockDelegateDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => [delegateFlag]);

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(
          result,
          equals(const [
            FeatureFlag(
              key: 'feature_login',
              isEnabled: true,
              isOverridden: true,
              hasRemoteSource: true,
              remoteValue: true, // refreshed from the delegate
            ),
          ]),
        );
      });

      test('should persist every resolved flag back to the cache', () async {
        const delegateFlags = [
          FeatureFlag(key: 'feature_login', isEnabled: true),
        ];
        when(() => mockCache.getAll()).thenAnswer((_) async => []);
        when(
          () => mockDelegateDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => delegateFlags);

        await dataSource.resolveFeatureFlags(definitions);

        verify(() => mockCache.put(delegateFlags.single)).called(1);
      });
    });

    group('updateFeatureFlag', () {
      test(
        'should store as a developer override when the flag is overridden',
        () async {
          const featureFlag = FeatureFlag(
            key: 'test_feature',
            isEnabled: true,
            isOverridden: true,
          );
          when(() => mockCache.putOverride(any())).thenAnswer((_) async {});

          await dataSource.updateFeatureFlag(featureFlag);

          verify(() => mockCache.putOverride(featureFlag)).called(1);
          verifyNever(() => mockCache.put(featureFlag));
        },
      );

      test(
        'should just put the flag in cache when the flag is not overridden',
        () async {
          const featureFlag = FeatureFlag(key: 'test_feature', isEnabled: true);

          await dataSource.updateFeatureFlag(featureFlag);

          verify(() => mockCache.put(featureFlag)).called(1);
          verifyNever(() => mockCache.putOverride(any()));
        },
      );
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
