import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_reporter/src/log/firebase_log_reporter.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group(FirebaseLogReporter, () {
    late _MockFbCrashlyticsController crashlyticsController;
    late FirebaseLogReporter firebaseLogReporter;

    StackTrace stackTraceWithFrames(int frameCount) {
      return StackTrace.fromString(
        List.generate(
          frameCount,
          (frameIndex) =>
              '#$frameIndex frame$frameIndex (file.dart:$frameIndex)',
        ).join('\n'),
      );
    }

    setUp(() {
      crashlyticsController = _MockFbCrashlyticsController();
      when(
        () => crashlyticsController.logMessage(any()),
      ).thenAnswer((_) async {});
      firebaseLogReporter = FirebaseLogReporter(crashlyticsController);
    });

    group('error', () {
      test('should log the tagged message when there is no stack trace', () {
        firebaseLogReporter.error('Load failed', tag: 'Repository');

        verify(
          () => crashlyticsController.logMessage('[Repository] Load failed'),
        ).called(1);
      });

      test('should log the stack trace under the message when there is '
          'one', () {
        firebaseLogReporter.error(
          'Load failed',
          tag: 'Repository',
          stacktrace: stackTraceWithFrames(2),
        );

        verify(
          () => crashlyticsController.logMessage(
            '[Repository] Load failed\n'
            '#0 frame0 (file.dart:0)\n'
            '#1 frame1 (file.dart:1)',
          ),
        ).called(1);
      });

      test('should log only the top eight frames when the stack trace is '
          'longer', () {
        firebaseLogReporter.error(
          'Load failed',
          tag: 'Repository',
          stacktrace: stackTraceWithFrames(20),
        );

        final loggedLine =
            verify(
                  () => crashlyticsController.logMessage(captureAny()),
                ).captured.single
                as String;
        final loggedFrames = loggedLine.split('\n').skip(1).toList();
        expect(loggedFrames, hasLength(8));
        expect(loggedFrames.last, '#7 frame7 (file.dart:7)');
      });
    });

    group('debug', () {
      test('should log the stack trace under the message when there is '
          'one', () {
        firebaseLogReporter.debug(
          'Loaded from cache',
          tag: 'Repository',
          stacktrace: stackTraceWithFrames(1),
        );

        verify(
          () => crashlyticsController.logMessage(
            '[Repository] Loaded from cache\n#0 frame0 (file.dart:0)',
          ),
        ).called(1);
      });
    });
  });
}

class _MockFbCrashlyticsController extends Mock
    implements FbCrashlyticsController {}
