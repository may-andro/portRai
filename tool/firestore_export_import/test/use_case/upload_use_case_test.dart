import 'package:firestore_export_import/use_case/upload_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_mock/mock_http_client.dart';
import '../_mock/mock_logger.dart';
import '../_mock/use_case/mock_get_api_header_use_case.dart';
import '../_mock/use_case/mock_get_data_to_upload_use_case.dart';

class UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(UriFake());
  });

  group(UploadUseCase, () {
    late UploadUseCase uploadUseCase;

    late MockGetApiHeaderUseCase mockedGetApiHeaderUseCase;
    late MockGetDataToUploadUseCase mockedGetDataToUploadUseCase;
    late MockHttpClient mockHttpClient;
    late MockLogger mockLogger;

    setUp(() {
      mockedGetApiHeaderUseCase = MockGetApiHeaderUseCase();
      mockedGetDataToUploadUseCase = MockGetDataToUploadUseCase();
      mockHttpClient = MockHttpClient();
      mockLogger = MockLogger();

      uploadUseCase = UploadUseCase(
        mockedGetApiHeaderUseCase,
        mockedGetDataToUploadUseCase,
        mockHttpClient,
        mockLogger,
      );
    });
    group('execute', () {
      const credentialsFilePath = 'mock_credentials.json';
      const dataFilePath = 'mock_data.json';
      const mockHeaders = {'Authorization': 'Bearer mockToken'};
      const mockBody = 'mockData';

      setUp(() {
        mockedGetApiHeaderUseCase.mockExecute(mockHeaders);
        mockedGetDataToUploadUseCase.mockExecute(mockBody);
      });

      test('should log success when upload is successful', () async {
        final mockResponse = MockHttpResponse(200, 'OK');
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await uploadUseCase.execute(
          'testCollection',
          credentialsFilePath,
          dataFilePath,
        );

        expect(
          mockLogger.infos,
          contains('Data uploaded to Firestore successfully'),
        );
      });

      test('should log error when upload fails', () async {
        final mockResponse = MockHttpResponse(400, 'Bad Request');
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        await uploadUseCase.execute(
          'testCollection',
          credentialsFilePath,
          dataFilePath,
        );

        expect(
          mockLogger.errors,
          contains('Data upload to Firestore failed: Bad Request'),
        );
      });

      test('should log abort message when exception is thrown', () async {
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('Network error'));

        await uploadUseCase.execute(
          'testCollection',
          credentialsFilePath,
          dataFilePath,
        );

        expect(
          mockLogger.errors.any(
            (msg) => msg.contains('Aborting the process due to failure:'),
          ),
          isTrue,
        );
      });
    });
  });
}
