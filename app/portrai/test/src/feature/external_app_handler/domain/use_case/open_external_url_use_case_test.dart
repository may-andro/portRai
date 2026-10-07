import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('plugins.flutter.io/url_launcher');

  group('OpenExternalUrlUseCase', () {
    late OpenExternalUrlUseCase useCase;
    final methodCalls = <MethodCall>[];

    void stubUrlLauncher(
      Future<Object?> Function(MethodCall methodCall) handler,
    ) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) {
            methodCalls.add(methodCall);
            return handler(methodCall);
          });
    }

    setUp(() {
      methodCalls.clear();
      useCase = OpenExternalUrlUseCase();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });

    test(
      'should launch the uri in an external application when forceWebView is false',
      () async {
        final uri = Uri.parse('https://example.com');
        stubUrlLauncher((methodCall) async => true);

        final result = await useCase(OpenExternalUrlParam(uri));

        expect(result.isRight, isTrue);
        expect(result.right, isTrue);
        expect(methodCalls, hasLength(1));
        expect(methodCalls.single.method, 'launch');
        expect(methodCalls.single.arguments, <String, Object>{
          'url': uri.toString(),
          'useSafariVC': false,
          'useWebView': false,
          'enableJavaScript': true,
          'enableDomStorage': true,
          'universalLinksOnly': false,
          'headers': <String, String>{},
        });
      },
    );

    test(
      'should launch the uri in an in-app web view when forceWebView is true',
      () async {
        final uri = Uri.parse('https://example.com/contact');
        stubUrlLauncher((methodCall) async => false);

        final result = await useCase(
          OpenExternalUrlParam(uri, forceWebView: true),
        );

        expect(result.isRight, isTrue);
        expect(result.right, isFalse);
        expect(methodCalls, hasLength(1));
        expect(methodCalls.single.method, 'launch');
        expect(methodCalls.single.arguments, <String, Object>{
          'url': uri.toString(),
          'useSafariVC': true,
          'useWebView': true,
          'enableJavaScript': true,
          'enableDomStorage': true,
          'universalLinksOnly': false,
          'headers': <String, String>{},
        });
      },
    );

    test(
      'should return OpenExternalUrlUnknownFailure when the launcher throws',
      () async {
        final uri = Uri.parse('https://example.com/error');
        final error = Exception('boom');
        stubUrlLauncher((methodCall) => Future<Object?>.error(error));

        final result = await useCase(OpenExternalUrlParam(uri));

        expect(result.isLeft, isTrue);
        expect(result.left, isA<OpenExternalUrlUnknownFailure>());
        expect(
          result.left.cause,
          isA<PlatformException>().having(
            (exception) => exception.message,
            'message',
            '$error',
          ),
        );
      },
    );
  });
}
