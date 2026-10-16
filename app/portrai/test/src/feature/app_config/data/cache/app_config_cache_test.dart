import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/data/cache/app_config_cache.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';

void main() {
  group('AppConfigCache', () {
    final cache = AppConfigCache();

    test(
      'should serialize the app config model to a json map when storing a value',
      () {
        const appConfig = PortraiAppConfigModel(
          minimumRequiredAppVersion: '1.2.3',
          aiImage: AiImageAppConfigModel(model: 'model', style: 'manga'),
        );

        expect(cache.serializeValue(appConfig), {
          'minimumRequiredAppVersion': '1.2.3',
          'aiImage': {'model': 'model', 'style': 'manga'},
        });
      },
    );

    test(
      'should deserialize the json map back to an app config model when reading a value',
      () {
        final result = cache.deserializeValue(const {
          'minimumRequiredAppVersion': '1.2.3',
        });

        expect(result.minimumRequiredAppVersion, '1.2.3');
        expect(result.aiImage, isNull);
      },
    );
  });
}
