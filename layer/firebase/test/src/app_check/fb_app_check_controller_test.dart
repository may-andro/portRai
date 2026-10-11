import 'package:firebase/src/app_check/fb_app_check_controller.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/app_check/mock_firebase_app_check.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ReCaptchaEnterpriseProvider('test-site-key'));
    registerFallbackValue(const AndroidPlayIntegrityProvider());
    registerFallbackValue(
      const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
  });

  group(FbAppCheckController, () {
    late MockFirebaseAppCheck appCheck;
    late FbAppCheckController controller;

    setUp(() {
      appCheck = MockFirebaseAppCheck()
        ..stubActivate()
        ..stubTokenAutoRefresh();
      controller = FbAppCheckController(appCheck);
    });

    test('should use debug providers when running a debug build', () async {
      await controller.initialiseAppCheck(webSiteKey: '');

      verify(
        () => appCheck.activate(
          providerWeb: any(named: 'providerWeb', that: isA<WebDebugProvider>()),
          providerAndroid: any(
            named: 'providerAndroid',
            that: isA<AndroidDebugProvider>(),
          ),
          providerApple: any(
            named: 'providerApple',
            that: isA<AppleDebugProvider>(),
          ),
        ),
      ).called(1);
    });

    test(
      'should forward configured tokens when debug providers are selected',
      () async {
        await controller.initialiseAppCheck(
          webSiteKey: '',
          androidDebugToken: ' android-test-token ',
          appleDebugToken: ' apple-test-token ',
          webDebugToken: ' web-test-token ',
        );

        verify(
          () => appCheck.activate(
            providerWeb: any(
              named: 'providerWeb',
              that: isA<WebDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                'web-test-token',
              ),
            ),
            providerAndroid: any(
              named: 'providerAndroid',
              that: isA<AndroidDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                'android-test-token',
              ),
            ),
            providerApple: any(
              named: 'providerApple',
              that: isA<AppleDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                'apple-test-token',
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'should let the SDK generate tokens when configured values are empty',
      () async {
        await controller.initialiseAppCheck(
          webSiteKey: '',
          androidDebugToken: ' ',
          appleDebugToken: ' ',
          webDebugToken: ' ',
        );

        verify(
          () => appCheck.activate(
            providerWeb: any(
              named: 'providerWeb',
              that: isA<WebDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                isNull,
              ),
            ),
            providerAndroid: any(
              named: 'providerAndroid',
              that: isA<AndroidDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                isNull,
              ),
            ),
            providerApple: any(
              named: 'providerApple',
              that: isA<AppleDebugProvider>().having(
                (provider) => provider.debugToken,
                'debugToken',
                isNull,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'should use real providers when debug providers are disabled',
      () async {
        await controller.initialiseAppCheck(
          webSiteKey: 'enterprise-site-key',
          useDebugProviders: false,
          androidDebugToken: 'unused-android-token',
          appleDebugToken: 'unused-apple-token',
          webDebugToken: 'unused-web-token',
        );

        verify(
          () => appCheck.activate(
            providerWeb: any(
              named: 'providerWeb',
              that: isA<ReCaptchaEnterpriseProvider>().having(
                (provider) => provider.siteKey,
                'siteKey',
                'enterprise-site-key',
              ),
            ),
            providerAndroid: any(
              named: 'providerAndroid',
              that: isA<AndroidPlayIntegrityProvider>(),
            ),
            providerApple: any(
              named: 'providerApple',
              that: isA<AppleAppAttestWithDeviceCheckFallbackProvider>(),
            ),
          ),
        ).called(1);
      },
    );

    test('should enable token refresh when activation succeeds', () async {
      await controller.initialiseAppCheck(webSiteKey: '');

      verifyInOrder([
        () => appCheck.activate(
          providerWeb: any(named: 'providerWeb'),
          providerAndroid: any(named: 'providerAndroid'),
          providerApple: any(named: 'providerApple'),
        ),
        () => appCheck.setTokenAutoRefreshEnabled(true),
      ]);
    });

    test(
      'should preserve the cause and stack trace when activation fails',
      () async {
        final error = StateError('activation failed');
        final stackTrace = StackTrace.current;
        appCheck.stubActivate(error: error, stackTrace: stackTrace);

        await expectLater(
          controller.initialiseAppCheck(webSiteKey: ''),
          throwsA(
            isA<AppCheckException>()
                .having((exception) => exception.cause, 'cause', same(error))
                .having(
                  (exception) => exception.stackTrace,
                  'stackTrace',
                  same(stackTrace),
                ),
          ),
        );
        verifyNever(() => appCheck.setTokenAutoRefreshEnabled(any()));
      },
    );

    test(
      'should propagate an exception when token refresh setup fails',
      () async {
        final error = StateError('refresh setup failed');
        appCheck.stubTokenAutoRefresh(error: error);

        await expectLater(
          controller.initialiseAppCheck(webSiteKey: ''),
          throwsA(
            isA<AppCheckException>().having(
              (exception) => exception.cause,
              'cause',
              same(error),
            ),
          ),
        );
      },
    );

    test(
      'should reject missing site keys when real web attestation is selected',
      () async {
        await expectLater(
          controller.initialiseAppCheck(
            webSiteKey: ' ',
            useDebugProviders: false,
          ),
          throwsA(
            isA<AppCheckException>().having(
              (exception) => exception.cause,
              'cause',
              isA<StateError>(),
            ),
          ),
        );
        verifyZeroInteractions(appCheck);
      },
      skip: !kIsWeb,
    );

    test(
      'should not require a web site key when using real native providers',
      () async {
        await controller.initialiseAppCheck(
          webSiteKey: '',
          useDebugProviders: false,
        );

        verify(() => appCheck.setTokenAutoRefreshEnabled(true)).called(1);
      },
      skip: kIsWeb,
    );
  });
}
