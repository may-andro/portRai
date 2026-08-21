import 'package:firestore_export_import/use_case/get_data_to_upload_use_case.dart';
import 'package:test/test.dart';

void main() {
  group(GetDataToUploadUseCase, () {
    late GetDataToUploadUseCase getDataToUploadUseCase;

    setUp(() {
      getDataToUploadUseCase = const GetDataToUploadUseCase();
    });

    group('execute', () {
      test('should return valid json for explicit documents format '
          '({ "documents": [{ "docId": "...", "fields": {...} }] })', () async {
        const path = 'test/test_data/test_data.json';
        const collection = 'testCollection';
        const projectId = 'testProjectId';
        final result = await getDataToUploadUseCase.execute(
          path,
          collection,
          projectId,
        );

        const expectedFirestoreJson =
            '{"writes":[{"update":{"name":"projects/testProjectId/databases/(default)/documents/testCollection/202535_NL-1000.1","fields":{"MEDIA_TYPE":{"stringValue":"Digital Billboard"},"OBJECT_FACE_ID":{"stringValue":"NL-1000.1"},"FACENR":{"integerValue":"1"},"STREET":{"stringValue":"Braak"},"STATION":{"stringValue":"Deventer"},"MUNICIPALITY_PART":{"stringValue":"Deventer"},"YYYYWW":{"integerValue":"202535"},"LATITUDE":{"doubleValue":52.245572},"LONGITUDE":{"doubleValue":6.146366},"OBJECTNR":{"stringValue":"NL-1000"},"KEY":{"stringValue":"202535_NL-1000.1"},"EXPRESSION":{"stringValue":"Business District Wk35"},"CAMPAIGN":{"stringValue":"New Year Discounts"},"geo":{"mapValue":{"fields":{"geopoint":{"geoPointValue":{"latitude":52.245572,"longitude":6.146366}},"geohash":{"stringValue":"u1k35z58"}}}}}}}]}';

        expect(result, expectedFirestoreJson);
      });

      test('should return valid json for locale/key-based format '
          '({ "docId": { ...fields... } })', () async {
        const path = 'test/test_data/test_data_locale.json';
        const collection = 'testCollection';
        const projectId = 'testProjectId';
        final result = await getDataToUploadUseCase.execute(
          path,
          collection,
          projectId,
        );

        const expectedFirestoreJson =
            '{"writes":[{"update":{"name":"projects/testProjectId/databases/(default)/documents/testCollection/en","fields":{"title":{"stringValue":"Software Engineer"},"company":{"stringValue":"ACME Corp"},"yearsOfExperience":{"integerValue":"5"},"salary":{"doubleValue":95000.5},"isRemote":{"booleanValue":true},"tags":{"arrayValue":{"values":[{"stringValue":"flutter"},{"stringValue":"dart"}]}}}}}]}';

        expect(result, expectedFirestoreJson);
      });
    });
  });
}
