import 'package:firestore_export_import/use_case/get_api_header_use_case.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class DownloadUseCase {
  DownloadUseCase(this._apiHeaderUseCase, this._client, this._logger);

  final GetApiHeaderUseCase _apiHeaderUseCase;
  final http.Client _client;
  final Logger _logger;

  Future<String?> execute(
    String collectionName,
    String credentialsFilePath,
  ) async {
    const projectId = 'portrai-96f2b';
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/';
    final baseUri = Uri.parse(url);
    final headers = await _apiHeaderUseCase.execute(credentialsFilePath);

    try {
      final response = await _client.get(baseUri, headers: headers);
      if (response.statusCode == 200) {
        _logger.i('Data downloaded from Firestore successfully');
        return response.body;
      } else {
        _logger.e('Data download from Firestore failed: \\${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Aborting the process due to failure: $e', error: e);
      return null;
    } finally {
      _client.close();
    }
  }
}
