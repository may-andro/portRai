import 'package:firestore_export_import/use_case/download_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_mock/mock_http_client.dart';
import '../_mock/mock_logger.dart';
import '../_mock/use_case/mock_get_api_header_use_case.dart';

class UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(UriFake());
  });

  group(DownloadUseCase, () {
    late DownloadUseCase useCase;

    late MockGetApiHeaderUseCase mockedGetApiHeaderUseCase;
    late MockHttpClient mockHttpClient;
    late MockLogger mockLogger;

    setUp(() {
      mockedGetApiHeaderUseCase = MockGetApiHeaderUseCase();
      mockHttpClient = MockHttpClient();
      mockLogger = MockLogger();

      useCase = DownloadUseCase(
        mockedGetApiHeaderUseCase,
        mockHttpClient,
        mockLogger,
      );
    });
    group('execute', () {
      const credentialsFilePath = 'mock_credentials.json';
      const collectionName = 'testCollection';
      const mockHeaders = {'Authorization': 'Bearer mockToken'};
      const firestoreUrl =
          'https://firestore.googleapis.com/v1/projects/portrai-96f2b/databases/(default)/documents/$collectionName/';

      setUp(() {
        mockedGetApiHeaderUseCase.mockExecute(mockHeaders);
      });

      test(
        'should return body and log success when download is successful',
        () async {
          const expectedBody = '{"documents": []}';
          mockHttpClient.mockGetOK(expectedBody, firestoreUrl, mockHeaders);

          final result = await useCase.execute(
            collectionName,
            credentialsFilePath,
          );

          expect(result, expectedBody);
          expect(
            mockLogger.infos,
            contains('Data downloaded from Firestore successfully'),
          );
        },
      );

      test('should return null and log error when download fails', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => MockHttpResponse(400, 'Bad Request'));

        final result = await useCase.execute(
          collectionName,
          credentialsFilePath,
        );

        expect(result, isNull);
        expect(
          mockLogger.errors.any(
            (msg) => msg.contains('Data download from Firestore failed:'),
          ),
          isTrue,
        );
      });

      test(
        'should return null and log abort message when exception is thrown',
        () async {
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenThrow(Exception('Network error'));

          final result = await useCase.execute(
            collectionName,
            credentialsFilePath,
          );

          expect(result, isNull);
          expect(
            mockLogger.errors.any(
              (msg) => msg.contains('Aborting the process due to failure:'),
            ),
            isTrue,
          );
        },
      );
    });
  });
}
