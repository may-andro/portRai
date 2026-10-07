import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_mail/open_mail.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';

void main() {
  const email = 'test@example.com';

  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
  });

  group('OpenEmailUseCase', () {
    late MockOpenExternalUrlUseCase openExternalUrlUseCase;
    late _TestableOpenEmailUseCase useCase;

    setUp(() {
      openExternalUrlUseCase = MockOpenExternalUrlUseCase();
    });

    test(
      'should compose an email in the mail app when the native launcher succeeds',
      () async {
        useCase = _TestableOpenEmailUseCase(
          openExternalUrlUseCase,
          isWebOverride: false,
        );
        useCase.composeEmailResult = true;

        final result = await useCase(email);

        expect(result.isRight, isTrue);
        expect(result.right, isTrue);
        expect(useCase.composeEmailCalls, [email]);
        verifyNever(() => openExternalUrlUseCase(any()));
      },
    );

    test(
      'should return NoEmailAppFoundFailure when no mail app opens',
      () async {
        useCase = _TestableOpenEmailUseCase(
          openExternalUrlUseCase,
          isWebOverride: false,
        );
        useCase.composeEmailResult = false;

        final result = await useCase(email);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<NoEmailAppFoundFailure>());
        expect(useCase.composeEmailCalls, [email]);
        verifyNever(() => openExternalUrlUseCase(any()));
      },
    );

    test(
      'should return EmailLaunchFailure when the native launcher throws',
      () async {
        useCase = _TestableOpenEmailUseCase(
          openExternalUrlUseCase,
          isWebOverride: false,
        );
        final error = Exception('failure');
        useCase.composeEmailError = error;

        final result = await useCase(email);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<EmailLaunchFailure>());
        expect(result.left.cause, same(error));
        expect(useCase.composeEmailCalls, [email]);
        verifyNever(() => openExternalUrlUseCase(any()));
      },
    );

    test('should launch a mailto uri when running on the web', () async {
      useCase = _TestableOpenEmailUseCase(
        openExternalUrlUseCase,
        isWebOverride: true,
      );
      openExternalUrlUseCase.stubCall(
        const Right<OpenExternalUrlFailure, bool>(true),
      );

      final result = await useCase(email);

      expect(result.isRight, isTrue);
      expect(result.right, isTrue);
      verify(
        () => openExternalUrlUseCase(
          any<OpenExternalUrlParam>(
            that: isA<OpenExternalUrlParam>()
                .having((param) => param.forceWebView, 'forceWebView', false)
                .having((param) => param.uri.scheme, 'scheme', 'mailto')
                .having((param) => param.uri.path, 'path', email)
                .having(
                  (param) => param.uri.queryParameters['subject'],
                  'subject',
                  OpenEmailUseCase.emailSubject,
                )
                .having(
                  (param) => param.uri.queryParameters['body'],
                  'body',
                  OpenEmailUseCase.emailBody,
                ),
          ),
        ),
      ).called(1);
    });

    test(
      'should return WebEmailLaunchFailure when the web launcher fails',
      () async {
        useCase = _TestableOpenEmailUseCase(
          openExternalUrlUseCase,
          isWebOverride: true,
        );
        final error = Exception('launch failed');
        openExternalUrlUseCase.stubCall(
          Left<OpenExternalUrlFailure, bool>(
            OpenExternalUrlFailure(cause: error),
          ),
        );

        final result = await useCase(email);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<WebEmailLaunchFailure>());
        expect(result.left.cause, same(error));
      },
    );
  });
}

class _TestableOpenEmailUseCase extends OpenEmailUseCase {
  _TestableOpenEmailUseCase(
    super.openExternalUrlUseCase, {
    required this.isWebOverride,
  });

  final bool isWebOverride;
  final composeEmailCalls = <String>[];
  bool composeEmailResult = true;
  Object? composeEmailError;

  @override
  bool get isWeb => isWebOverride;

  @override
  Future<OpenMailAppResult> composeEmail(String input) async {
    composeEmailCalls.add(input);

    if (composeEmailError != null) {
      throw composeEmailError!;
    }

    return OpenMailAppResult(didOpen: composeEmailResult);
  }
}
