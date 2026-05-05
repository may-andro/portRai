import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:firestore_export_import/di/di.dart';
import 'package:firestore_export_import/use_case/use_case.dart';
import 'package:logger/logger.dart';

class ImportCommand extends Command<dynamic> {
  ImportCommand(this._downloadUseCase) {
    argParser.addOption(
      'collection',
      abbr: 'c',
      help: 'Firestore collection to import/download',
    );
    argParser.addOption(
      'secrets',
      abbr: 's',
      help: 'JSON file path for service account credentials',
    );
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output file path to save imported data',
    );
  }

  final DownloadUseCase _downloadUseCase;

  @override
  final name = 'import';

  @override
  final description = 'Import collection data from firestore';

  @override
  Future<void> run() async {
    final collectionName = argResults?['collection'] as String?;
    final credentialsFilePath = argResults?['secrets'] as String?;
    final outputFilePath = argResults?['output'] as String?;

    final logger = locator<Logger>();
    logger.i('Import command started');
    logger.i('Collection: $collectionName');
    logger.i('Credentials: $credentialsFilePath');
    logger.i('Output: $outputFilePath');

    if (collectionName == null) {
      logger.e('Collection name not found');
      return;
    }
    if (credentialsFilePath == null) {
      logger.e('Credentials file path not found');
      return;
    }
    if (outputFilePath == null) {
      logger.e('Output file path not found');
      return;
    }

    logger.i('Starting download process...');
    final data = await _downloadUseCase.execute(
      collectionName,
      credentialsFilePath,
    );
    if (data != null) {
      final file = File(outputFilePath);
      await file.writeAsString(data);
      logger.i('Data exported to $outputFilePath');
    } else {
      logger.e('No data received from download use case');
    }
  }
}
