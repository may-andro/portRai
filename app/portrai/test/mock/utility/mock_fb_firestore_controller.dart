import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbFirestoreController extends Mock implements FbFirestoreController {}

extension MockFbFirestoreControllerStub on MockFbFirestoreController {
  /// Stubs `getDocumentFromCollection(collectionPath, documentPath)` to
  /// return [document].
  void stubGetDocumentFromCollection(Map<String, dynamic>? document) {
    when(
      () => getDocumentFromCollection(any(), any()),
    ).thenAnswer((_) async => document);
  }

  /// Stubs `getDocumentFromCollection(collectionPath, documentPath)` to
  /// throw [error].
  void stubGetDocumentFromCollectionThrows(Object error) {
    when(() => getDocumentFromCollection(any(), any())).thenThrow(error);
  }
}
