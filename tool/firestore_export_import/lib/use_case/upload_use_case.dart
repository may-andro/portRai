import 'package:firestore_export_import/use_case/get_api_header_use_case.dart';
import 'package:firestore_export_import/use_case/get_data_to_upload_use_case.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class UploadUseCase {
  UploadUseCase(
    this._apiHeaderUseCase,
    this._dataToUploadUseCase,
    this._client,
    this._logger,
  );

  final GetApiHeaderUseCase _apiHeaderUseCase;
  final GetDataToUploadUseCase _dataToUploadUseCase;
  final http.Client _client;
  final Logger _logger;

  Future<void> execute(
    String collectionName,
    String credentialsFilePath,
    String dataFilePath,
  ) async {
    const projectId = 'portrai-96f2b';
    const url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:batchWrite';
    final baseUri = Uri.parse(url);

    final headers = await _apiHeaderUseCase.execute(credentialsFilePath);
    final body = await _dataToUploadUseCase.execute(
      dataFilePath,
      collectionName,
      projectId,
    );

    try {
      final response = await _client.post(
        baseUri,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        _logger.i('Data uploaded to Firestore successfully');
      } else {
        _logger.e('Data upload to Firestore failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Aborting the process due to failure: $e', error: e);
    } finally {
      _client.close();
    }
  }
}
