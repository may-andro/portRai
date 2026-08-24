import 'package:firestore_export_import/command/export_command.dart';
import 'package:firestore_export_import/command/import_command.dart';
import 'package:firestore_export_import/use_case/use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

GetIt locator = GetIt.instance;

void setUpDI() {
  _addHttpClientToDI();
  _addLoggerToDI();
  _addUseCasesToDI();
  _addCommandsToDI();
}

void _addHttpClientToDI() {
  locator.registerFactory<http.Client>(() => http.Client());
}

void _addLoggerToDI() {
  locator.registerLazySingleton<Logger>(
    () => Logger(
      printer: SimplePrinter(printTime: true),
      output: ConsoleOutput(),
      level: Level.debug,
    ),
  );
}

void _addUseCasesToDI() {
  locator.registerFactory<GetDataToUploadUseCase>(
    () => const GetDataToUploadUseCase(),
  );

  locator.registerFactory<GetClientCredentialsUseCase>(
    () => const GetClientCredentialsUseCase(),
  );

  locator.registerFactory<GetAuthTokenUseCase>(
    () => GetAuthTokenUseCase(
      locator<http.Client>(),
      locator<GetClientCredentialsUseCase>(),
    ),
  );

  locator.registerFactory<GetApiHeaderUseCase>(
    () => GetApiHeaderUseCase(locator<GetAuthTokenUseCase>()),
  );

  locator.registerFactory<UploadUseCase>(
    () => UploadUseCase(
      locator<GetApiHeaderUseCase>(),
      locator<GetDataToUploadUseCase>(),
      locator<http.Client>(),
      locator<Logger>(),
    ),
  );

  locator.registerFactory<DownloadUseCase>(
    () => DownloadUseCase(
      locator<GetApiHeaderUseCase>(),
      locator<http.Client>(),
      locator<Logger>(),
    ),
  );
}

void _addCommandsToDI() {
  locator.registerFactory<ImportCommand>(
    () => ImportCommand(locator<DownloadUseCase>()),
  );

  locator.registerFactory<ExportCommand>(
    () => ExportCommand(locator<UploadUseCase>()),
  );
}
