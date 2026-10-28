import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';

void main() {
  group('PortraiAppConfigModel', () {
    test('fromJson should parse the nested AI image config', () {
      final model = PortraiAppConfigModel.fromJson(const {
        'minimumRequiredAppVersion': '1.2.3',
        'aiImage': {'model': 'model', 'style': 'avatar'},
      });

      expect(model.minimumRequiredAppVersion, '1.2.3');
      expect(model.aiImage?.model, 'model');
      expect(model.aiImage?.style, 'avatar');
    });

    test('fromJson should leave the AI image null when absent', () {
      final model = PortraiAppConfigModel.fromJson(const {
        'minimumRequiredAppVersion': '1.2.3',
      });

      expect(model.aiImage, isNull);
    });

    test('fromJson should parse the legal links', () {
      final model = PortraiAppConfigModel.fromJson(const {
        'minimumRequiredAppVersion': '1.2.3',
        'termsUrl': 'https://legal.example.com/terms',
        'privacyPolicyUrl': 'https://legal.example.com/privacy',
      });

      expect(model.termsUrl, 'https://legal.example.com/terms');
      expect(model.privacyPolicyUrl, 'https://legal.example.com/privacy');
    });

    test('toJson should omit null values', () {
      const model = PortraiAppConfigModel(minimumRequiredAppVersion: '1.2.3');

      expect(model.toJson(), {'minimumRequiredAppVersion': '1.2.3'});
    });
  });
}
