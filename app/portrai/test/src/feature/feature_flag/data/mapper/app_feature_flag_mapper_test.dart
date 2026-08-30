import 'package:feature_flag/feature_flag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/data/mapper/app_feature_flag_mapper.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

void main() {
  const definition = AppFeatureFlagDefinition(
    key: 'feature_services_section',
    defaultValue: false,
    displayName: 'Services Section',
    description: 'Enables the services section on portfolio page',
  );

  group('AppFeatureFlagMapper', () {
    const mapper = AppFeatureFlagMapper();

    group('from', () {
      test(
        'should map an app entity to a layer feature flag when all fields are set',
        () {
          const entity = AppFeatureFlagEntity(
            flag: definition,
            isEnabled: true,
            isOverridden: true,
            hasRemoteSource: true,
            remoteValue: false,
          );

          final result = mapper.from(entity);

          expect(
            result,
            const FeatureFlag(
              key: 'feature_services_section',
              isEnabled: true,
              isOverridden: true,
              hasRemoteSource: true,
              remoteValue: false,
            ),
          );
        },
      );

      test(
        'should map default remote fields when the app entity has no remote metadata',
        () {
          const entity = AppFeatureFlagEntity(
            flag: definition,
            isEnabled: false,
            isOverridden: false,
          );

          final result = mapper.from(entity);

          expect(
            result,
            const FeatureFlag(
              key: 'feature_services_section',
              isEnabled: false,
            ),
          );
        },
      );
    });

    group('to', () {
      test(
        'should map a layer feature flag to an app entity when a definition is provided',
        () {
          const model = FeatureFlag(
            key: 'feature_services_section',
            isEnabled: true,
            isOverridden: true,
            hasRemoteSource: true,
            remoteValue: false,
          );

          final result = mapper.to(model, definition);

          expect(
            result,
            const AppFeatureFlagEntity(
              flag: definition,
              isEnabled: true,
              isOverridden: true,
              hasRemoteSource: true,
              remoteValue: false,
            ),
          );
        },
      );

      test(
        'should retain presentation metadata when mapping back to an app entity',
        () {
          const model = FeatureFlag(
            key: 'feature_services_section',
            isEnabled: false,
          );

          final result = mapper.to(model, definition);

          expect(result.key, definition.key);
          expect(result.name, definition.displayName);
          expect(result.description, definition.description);
        },
      );
    });
  });
}
