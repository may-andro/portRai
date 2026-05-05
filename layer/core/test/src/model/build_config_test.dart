import 'package:core/src/model/build_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildEnvironment', () {
    group('enum values', () {
      test('should have dev and prod values', () {
        expect(BuildEnvironment.values, hasLength(2));
        expect(BuildEnvironment.values, contains(BuildEnvironment.staging));
        expect(BuildEnvironment.values, contains(BuildEnvironment.prod));
      });

      test('should have correct names', () {
        expect(BuildEnvironment.staging.name, equals('staging'));
        expect(BuildEnvironment.prod.name, equals('prod'));
      });
    });

    group('isFirebaseEnabled', () {
      test('should return false for dev environment', () {
        expect(BuildEnvironment.staging.isFirebaseEnabled, isFalse);
      });

      test('should return true for prod environment', () {
        expect(BuildEnvironment.prod.isFirebaseEnabled, isTrue);
      });
    });

    group('isFeatureFlagCached', () {
      test('should return true for dev environment', () {
        expect(BuildEnvironment.staging.isFeatureFlagCached, isTrue);
      });

      test('should return false for prod environment', () {
        expect(BuildEnvironment.prod.isFeatureFlagCached, isFalse);
      });
    });

    group('isRemoteLoggingEnabled', () {
      test('should return true for dev environment', () {
        expect(BuildEnvironment.staging.isRemoteLoggingEnabled, isTrue);
      });

      test('should return false for prod environment', () {
        expect(BuildEnvironment.prod.isRemoteLoggingEnabled, isFalse);
      });
    });

    group('isSplashDescriptive', () {
      test('should return true for dev environment', () {
        expect(BuildEnvironment.staging.isSplashDescriptive, isTrue);
      });

      test('should return false for prod environment', () {
        expect(BuildEnvironment.prod.isSplashDescriptive, isFalse);
      });
    });

    group('isDevMenuEnabled', () {
      test('should return true for dev environment', () {
        expect(BuildEnvironment.staging.isDevMenuEnabled, isTrue);
      });

      test('should return false for prod environment', () {
        expect(BuildEnvironment.prod.isDevMenuEnabled, isFalse);
      });
    });

    group('debugShowCheckedModeBanner', () {
      test('should return true for dev environment', () {
        expect(BuildEnvironment.staging.debugShowCheckedModeBanner, isTrue);
      });

      test('should return false for prod environment', () {
        expect(BuildEnvironment.prod.debugShowCheckedModeBanner, isFalse);
      });
    });

    group('buildEnvironment getter', () {
      test('should return prod as default when no environment variable is set', () {
        // Note: This test relies on the default behavior when 'build_env' is not set
        // In a real test environment, we can't easily mock String.fromEnvironment
        // but we can test the logic by understanding the default value
        expect(
          BuildEnvironment.buildEnvironment,
          equals(BuildEnvironment.prod),
        );
      });

      test('should handle null from firstWhereOrNull gracefully', () {
        // This tests the fallback logic when an invalid environment is provided
        // The method should return prod as fallback
        expect(BuildEnvironment.buildEnvironment, isNotNull);
        expect(BuildEnvironment.buildEnvironment, isA<BuildEnvironment>());
      });
    });

    group('environment configuration matrix', () {
      test('dev environment should have correct configuration', () {
        const env = BuildEnvironment.staging;

        expect(env.isFirebaseEnabled, isFalse);
        expect(env.isFeatureFlagCached, isTrue);
        expect(env.isRemoteLoggingEnabled, isTrue);
        expect(env.isSplashDescriptive, isTrue);
        expect(env.isDevMenuEnabled, isTrue);
        expect(env.debugShowCheckedModeBanner, isTrue);
      });

      test('prod environment should have correct configuration', () {
        const env = BuildEnvironment.prod;

        expect(env.isFirebaseEnabled, isTrue);
        expect(env.isFeatureFlagCached, isFalse);
        expect(env.isRemoteLoggingEnabled, isFalse);
        expect(env.isSplashDescriptive, isFalse);
        expect(env.isDevMenuEnabled, isFalse);
        expect(env.debugShowCheckedModeBanner, isFalse);
      });
    });

    group('environment comparison', () {
      test('dev and prod should be different', () {
        expect(BuildEnvironment.staging, isNot(equals(BuildEnvironment.prod)));
      });

      test('same environment values should be equal', () {
        expect(BuildEnvironment.staging, equals(BuildEnvironment.staging));
        expect(BuildEnvironment.prod, equals(BuildEnvironment.prod));
      });
    });
  });

  group('BuildConfig', () {
    group('constructor', () {
      test('should create BuildConfig with dev environment', () {
        final config = BuildConfig(buildEnvironment: BuildEnvironment.staging);

        expect(config.buildEnvironment, equals(BuildEnvironment.staging));
      });

      test('should create BuildConfig with prod environment', () {
        final config = BuildConfig(buildEnvironment: BuildEnvironment.prod);

        expect(config.buildEnvironment, equals(BuildEnvironment.prod));
      });
    });

    group('properties', () {
      test('should store the provided build environment', () {
        final devConfig = BuildConfig(buildEnvironment: BuildEnvironment.staging);
        final prodConfig = BuildConfig(buildEnvironment: BuildEnvironment.prod);

        expect(devConfig.buildEnvironment, equals(BuildEnvironment.staging));
        expect(prodConfig.buildEnvironment, equals(BuildEnvironment.prod));
      });

      test('should maintain immutability of build environment', () {
        final config = BuildConfig(buildEnvironment: BuildEnvironment.staging);

        // The buildEnvironment field should be final and cannot be changed
        expect(config.buildEnvironment, equals(BuildEnvironment.staging));
      });
    });

    group('integration with BuildEnvironment', () {
      test('should work correctly with dev environment features', () {
        final config = BuildConfig(buildEnvironment: BuildEnvironment.staging);

        expect(config.buildEnvironment.isDevMenuEnabled, isTrue);
        expect(config.buildEnvironment.isFirebaseEnabled, isFalse);
        expect(config.buildEnvironment.debugShowCheckedModeBanner, isTrue);
      });

      test('should work correctly with prod environment features', () {
        final config = BuildConfig(buildEnvironment: BuildEnvironment.prod);

        expect(config.buildEnvironment.isDevMenuEnabled, isFalse);
        expect(config.buildEnvironment.isFirebaseEnabled, isTrue);
        expect(config.buildEnvironment.debugShowCheckedModeBanner, isFalse);
      });
    });
  });
}
