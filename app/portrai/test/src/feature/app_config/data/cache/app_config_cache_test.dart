import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/cache/app_config_cache.dart';

void main() {
  group('AppConfigCache', () {
    final cache = AppConfigCache();

    test(
      'should serialize the app config entity to a json map when storing a value',
      () {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.2.3',
        );

        expect(cache.serializeValue(appConfig), {
          'minimumRequiredAppVersion': '1.2.3',
        });
      },
    );

    test(
      'should deserialize the json map back to an app config entity when reading a value',
      () {
        final result = cache.deserializeValue(const {
          'minimumRequiredAppVersion': '1.2.3',
        });

        expect(
          result,
          const PortraiAppConfigEntity(minimumRequiredAppVersion: '1.2.3'),
        );
      },
    );
  });
}
