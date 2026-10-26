import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:portrai/src/utility/log_use_case_interceptor.dart';

import '../../mock/utility/mock_log_reporter.dart';

void main() {
  group('LogUseCaseInterceptor', () {
    late LogUseCaseInterceptor interceptor;
    late MockLogReporter mockLogReporter;

    setUp(() {
      mockLogReporter = MockLogReporter();
      interceptor = LogUseCaseInterceptor(mockLogReporter);
    });

    group('onCall', () {
      test('should log param when onCall is invoked', () {
        interceptor.onCall<String>('MyUseCase', 'some_param');

        verify(
          () => mockLogReporter.debug(
            'Calling with params: some_param',
            tag: 'MyUseCase',
          ),
        ).called(1);
      });

      test('should log null param when onCall is invoked with null', () {
        interceptor.onCall<String?>('NullUseCase', null);

        verify(
          () => mockLogReporter.debug(
            'Calling with params: null',
            tag: 'NullUseCase',
          ),
        ).called(1);
      });
    });

    group('onError', () {
      test(
        'should omit backend details and raw causes when logging remote failures',
        () {
          const details =
              'Your credits are depleted. Enable billing to continue.';
          final exception = AiServerException(
            StateError('secret prompt and server body'),
            StackTrace.current,
            serviceMessage: details,
          );
          final failure = AskRemotePortfolioQuestionUnknownFailure(
            cause: exception,
            serviceMessage: exception.serviceMessage,
          );
          interceptor.onError('RemoteUseCase', failure, null);
          final message =
              verify(
                    () => mockLogReporter.error(
                      captureAny(),
                      tag: 'RemoteUseCase',
                      error: failure,
                    ),
                  ).captured.single
                  as String;
          expect(message, contains('Firebase AI request failed'));
          expect(message, isNot(contains(details)));
          expect(message, isNot(contains('secret')));
        },
      );

      test('should log error and stacktrace when onError is called', () {
        final error = Exception('something went wrong');
        final stackTrace = StackTrace.current;

        interceptor.onError('FailingUseCase', error, stackTrace);

        verify(
          () => mockLogReporter.error(
            'Error detected: $error',
            tag: 'FailingUseCase',
            error: error,
            stacktrace: stackTrace,
          ),
        ).called(1);
      });

      test(
        'should log error with null stacktrace when onError is called without stacktrace',
        () {
          final error = Exception('no stack');

          interceptor.onError('UseCase', error, null);

          verify(
            () => mockLogReporter.error(
              'Error detected: $error',
              tag: 'UseCase',
              error: error,
            ),
          ).called(1);
        },
      );
    });

    group('onSuccess', () {
      test(
        'should log result type and value when onSuccess is called with string',
        () {
          interceptor.onSuccess<String>('MyUseCase', 'result_value');

          verify(
            () => mockLogReporter.debug(
              'Success: String result_value',
              tag: 'MyUseCase',
            ),
          ).called(1);
        },
      );

      test(
        'should log int result correctly when onSuccess is called with int',
        () {
          interceptor.onSuccess<int>('CountUseCase', 42);

          verify(
            () => mockLogReporter.debug('Success: int 42', tag: 'CountUseCase'),
          ).called(1);
        },
      );
    });
  });
}
