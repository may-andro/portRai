import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';

void main() {
  group('AssetSource', () {
    test('should return the real json path when the source is real', () {
      expect(
        AssetSource.real.assetPath('profile'),
        'assets/dashboard/profile.json',
      );
    });

    test(
      'should return the template json path when the source is template',
      () {
        expect(
          AssetSource.template.assetPath('profile'),
          'assets/dashboard/profile.template.json',
        );
      },
    );

    test('should report template only when the source is template', () {
      expect(AssetSource.template.isTemplate, isTrue);
      expect(AssetSource.real.isTemplate, isFalse);
    });
  });
}
