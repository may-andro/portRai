import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

void main() {
  group('GetPrivacyPolicyUrlUseCase', () {
    Future<Uri> urlOf(String? value) async {
      final result = await GetPrivacyPolicyUrlUseCase(
        PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
          privacyPolicyUrl: value,
        ),
      )();
      return result.right;
    }

    test(
      'should return the configured page when it is a web address',
      () async {
        expect(
          await urlOf(' https://legal.example.com/privacy-policy '),
          Uri.parse('https://legal.example.com/privacy-policy'),
        );
      },
    );

    for (final value in [
      null,
      '',
      'not a url',
      'mailto:me@example.com',
      '/privacy-policy',
    ]) {
      test('should return the hosted page when the link is $value', () async {
        expect(await urlOf(value), GetPrivacyPolicyUrlUseCase.defaultUrl);
      });
    }
  });
}
