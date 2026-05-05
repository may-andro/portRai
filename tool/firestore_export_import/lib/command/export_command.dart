import 'package:args/command_runner.dart';
import 'package:firestore_export_import/di/di.dart';
import 'package:firestore_export_import/use_case/use_case.dart';
import 'package:logger/logger.dart';

class ExportCommand extends Command<dynamic> {
  ExportCommand(this._uploadUseCase) {
    argParser.addOption(
      'collection',
      abbr: 'c',
      help: 'Firebase collection name to export/upload',
    );
    argParser.addOption(
      'secrets',
      abbr: 's',
      help: 'JSON file path for service account credentials',
    );
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'JSON File path for data to export/upload',
    );
  }

  final UploadUseCase _uploadUseCase;

  @override
  final name = 'export';

  @override
  final description = 'Export data to the firestore collection';

  @override
  void run() {
    final collectionName = argResults?['collection'] as String?;
    final credentialsFilePath = argResults?['secrets'] as String?;
    final dataFilePath = argResults?['path'] as String?;

    final logger = locator<Logger>();

    if (collectionName == null) {
      logger.e('Collection name not found');
      return;
    }

    if (credentialsFilePath == null) {
      logger.e('Credentials file path not found');
      return;
    }

    if (dataFilePath == null) {
      logger.e('File path to upload not found');
      return;
    }
    _uploadUseCase.execute(collectionName, credentialsFilePath, dataFilePath);
  }
}
