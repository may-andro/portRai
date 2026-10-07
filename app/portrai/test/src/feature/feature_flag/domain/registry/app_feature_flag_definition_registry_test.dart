import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/entity/app_feature_flag_definition.dart';
import 'package:portrai/src/feature/feature_flag/domain/registry/app_feature_flag_definition_registry.dart';

import '../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(Exception('fallback'));
  });

  group('AppFeatureFlagDefinitionRegistry', () {
    late MockLogReporter logReporter;
    late AppFeatureFlagDefinitionRegistry registry;

    setUp(() {
      logReporter = MockLogReporter();
      registry = AppFeatureFlagDefinitionRegistry(logReporter);
    });

    test('should return registered definitions when registration succeeds', () {
      registry.register(testimonialsDefinition);
      registry.register(servicesDefinition);

      expect(registry.all, [testimonialsDefinition, servicesDefinition]);
    });

    test(
      'should ignore duplicate keys when the same flag is registered twice',
      () {
        registry.register(testimonialsDefinition);
        registry.register(
          const AppFeatureFlagDefinition(
            key: 'feature_testimonials_section',
            defaultValue: true,
            displayName: 'Duplicate Testimonials Section',
          ),
        );

        expect(registry.all, [testimonialsDefinition]);
        verify(
          () => logReporter.error(
            any<String>(),
            stacktrace: any<StackTrace>(named: 'stacktrace'),
            error: any<Object>(named: 'error'),
            tag: 'AppFeatureFlagDefinitionRegistry',
          ),
        ).called(1);
      },
    );

    test('should return an unmodifiable list when reading all definitions', () {
      registry.register(testimonialsDefinition);

      expect(
        () => registry.all.add(servicesDefinition),
        throwsUnsupportedError,
      );
    });
  });
}
