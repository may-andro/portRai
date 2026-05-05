import 'package:args/command_runner.dart';
import 'package:firestore_export_import/firestore_export_import.dart';
import 'package:logger/logger.dart';

Future<void> main(List<String> args) async {
  init();
  final runner = CommandRunner<void>(
    'firestore_export_import',
    'A tool for import/export json content to/from FireStore',
  );
  runner.addCommand(importCommand);
  runner.addCommand(exportCommand);
  await runner.run(args).catchError((dynamic error) => Logger().e(error));
}
