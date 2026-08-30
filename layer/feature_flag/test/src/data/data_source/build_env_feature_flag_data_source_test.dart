import 'package:core/core.dart';
import 'package:feature_flag/src/data/data_source/build_env_feature_flag_data_source.dart';
import 'package:feature_flag/src/data/data_source/feature_flag_data_source.dart';
import 'package:feature_flag/src/feature_flag.dart';
import 'package:feature_flag/src/feature_flag_definition.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock/mock_feature_flag_data_source.dart';

void main() {
  setUpAll(() {
    // Register fallback value for FeatureFlag when using any() matchers
    registerFallbackValue(const FeatureFlag(key: 'fake', isEnabled: false));
  });

  group('BuildEnvFeatureFlagDataSource', () {
    const definitions = [
      FeatureFlagDefinition(key: 'feature_login', defaultValue: false),
    ];

    late MockFeatureFlagDataSource mockCacheDataSource;
    late MockFeatureFlagDataSource mockRemoteDataSource;

    setUp(() {
      mockCacheDataSource = MockFeatureFlagDataSource();
      mockRemoteDataSource = MockFeatureFlagDataSource();
    });

    group('constructor delegation', () {
      test('should delegate to cache data source when environment is dev', () {
        final buildConfig = BuildConfig(
          buildEnvironment: BuildEnvironment.staging,
        );

        final dataSource = BuildEnvFeatureFlagDataSource(
          buildConfig,
          mockCacheDataSource,
          mockRemoteDataSource,
        );

        expect(dataSource, isA<BuildEnvFeatureFlagDataSource>());
        expect(dataSource, isA<FeatureFlagDataSource>());
      });

      test(
        'should delegate to remote data source when environment is prod',
        () {
          final buildConfig = BuildConfig(
            buildEnvironment: BuildEnvironment.prod,
          );

          final dataSource = BuildEnvFeatureFlagDataSource(
            buildConfig,
            mockCacheDataSource,
            mockRemoteDataSource,
          );

          expect(dataSource, isA<BuildEnvFeatureFlagDataSource>());
          expect(dataSource, isA<FeatureFlagDataSource>());
        },
      );
    });

    group('resolveFeatureFlags', () {
      test('should return flags from cache data source when environment is '
          'staging', () async {
        const expectedFlags = [
          FeatureFlag(key: 'feature_login', isEnabled: true),
        ];
        final buildConfig = BuildConfig(
          buildEnvironment: BuildEnvironment.staging,
        );
        when(
          () => mockCacheDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => expectedFlags);

        final dataSource = BuildEnvFeatureFlagDataSource(
          buildConfig,
          mockCacheDataSource,
          mockRemoteDataSource,
        );

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(result, equals(expectedFlags));
        verify(
          () => mockCacheDataSource.resolveFeatureFlags(definitions),
        ).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return flags from remote data source when environment is '
          'prod', () async {
        const expectedFlags = [
          FeatureFlag(
            key: 'feature_login',
            isEnabled: false,
            hasRemoteSource: true,
            remoteValue: false,
          ),
        ];
        final buildConfig = BuildConfig(
          buildEnvironment: BuildEnvironment.prod,
        );
        when(
          () => mockRemoteDataSource.resolveFeatureFlags(definitions),
        ).thenAnswer((_) async => expectedFlags);

        final dataSource = BuildEnvFeatureFlagDataSource(
          buildConfig,
          mockCacheDataSource,
          mockRemoteDataSource,
        );

        final result = await dataSource.resolveFeatureFlags(definitions);

        expect(result, equals(expectedFlags));
        verify(
          () => mockRemoteDataSource.resolveFeatureFlags(definitions),
        ).called(1);
        verifyZeroInteractions(mockCacheDataSource);
      });
    });

    group('updateFeatureFlag', () {
      test(
        'should delegate to cache data source when environment is staging',
        () async {
          const featureFlag = FeatureFlag(key: 'test_feature', isEnabled: true);
          final buildConfig = BuildConfig(
            buildEnvironment: BuildEnvironment.staging,
          );
          when(
            () => mockCacheDataSource.updateFeatureFlag(any()),
          ).thenAnswer((_) {});

          final dataSource = BuildEnvFeatureFlagDataSource(
            buildConfig,
            mockCacheDataSource,
            mockRemoteDataSource,
          );

          await dataSource.updateFeatureFlag(featureFlag);

          verify(
            () => mockCacheDataSource.updateFeatureFlag(featureFlag),
          ).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should delegate to remote data source when environment is prod',
        () async {
          const featureFlag = FeatureFlag(
            key: 'remote_feature',
            isEnabled: true,
          );
          final buildConfig = BuildConfig(
            buildEnvironment: BuildEnvironment.prod,
          );
          when(
            () => mockRemoteDataSource.updateFeatureFlag(any()),
          ).thenAnswer((_) {});

          final dataSource = BuildEnvFeatureFlagDataSource(
            buildConfig,
            mockCacheDataSource,
            mockRemoteDataSource,
          );

          await dataSource.updateFeatureFlag(featureFlag);

          verify(
            () => mockRemoteDataSource.updateFeatureFlag(featureFlag),
          ).called(1);
          verifyZeroInteractions(mockCacheDataSource);
        },
      );
    });

    group('reset', () {
      test(
        'should delegate to cache data source when environment is staging',
        () async {
          final buildConfig = BuildConfig(
            buildEnvironment: BuildEnvironment.staging,
          );
          when(() => mockCacheDataSource.reset()).thenAnswer((_) {});

          final dataSource = BuildEnvFeatureFlagDataSource(
            buildConfig,
            mockCacheDataSource,
            mockRemoteDataSource,
          );

          await dataSource.reset();

          verify(() => mockCacheDataSource.reset()).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should delegate to remote data source when environment is prod',
        () async {
          final buildConfig = BuildConfig(
            buildEnvironment: BuildEnvironment.prod,
          );
          when(() => mockRemoteDataSource.reset()).thenAnswer((_) {});

          final dataSource = BuildEnvFeatureFlagDataSource(
            buildConfig,
            mockCacheDataSource,
            mockRemoteDataSource,
          );

          await dataSource.reset();

          verify(() => mockRemoteDataSource.reset()).called(1);
          verifyZeroInteractions(mockCacheDataSource);
        },
      );
    });
  });
}
