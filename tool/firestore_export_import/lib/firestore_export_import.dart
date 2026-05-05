import 'package:firestore_export_import/command/export_command.dart';
import 'package:firestore_export_import/command/import_command.dart';
import 'package:firestore_export_import/di/di.dart';

void init() => setUpDI();

ImportCommand get importCommand => locator<ImportCommand>();
ExportCommand get exportCommand => locator<ExportCommand>();
