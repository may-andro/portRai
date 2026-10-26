import 'package:args/command_runner.dart';
import 'package:firestore_export_import/command/export_command.dart';
import 'package:firestore_export_import/di/di.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_mock/mock_logger.dart';
import '../_mock/use_case/mock_upload_use_case.dart';

void main() {
  group(ExportCommand, () {
    late MockUploadUseCase mockUploadUseCase;
    late MockLogger mockLogger;
    late CommandRunner<void> runner;

    const args = [
      'export',
      '-c',
      'items',
      '-s',
      'credentials.json',
      '-p',
      'data.json',
    ];

    setUp(() {
      mockUploadUseCase = MockUploadUseCase();
      mockLogger = MockLogger();
      locator.registerSingleton<Logger>(mockLogger);
      runner = CommandRunner<void>('test', 'test')
        ..addCommand(ExportCommand(mockUploadUseCase));
    });

    tearDown(locator.reset);

    test('completes after the upload completes', () async {
      var uploaded = false;
      mockUploadUseCase.mockExecute(() async {
        await Future<void>.delayed(Duration.zero);
        uploaded = true;
      });

      await runner.run(args);

      expect(uploaded, isTrue);
      verify(
        () =>
            mockUploadUseCase.execute('items', 'credentials.json', 'data.json'),
      ).called(1);
    });

    test('passes an upload error to the caller', () async {
      mockUploadUseCase.mockExecute(() async => throw Exception('failed'));

      await expectLater(runner.run(args), throwsException);
    });

    test('logs an error and skips the upload without a collection', () async {
      await runner.run(['export', '-s', 'credentials.json', '-p', 'data.json']);

      expect(mockLogger.errors, ['Collection name not found']);
      verifyNever(() => mockUploadUseCase.execute(any(), any(), any()));
    });
  });
}
