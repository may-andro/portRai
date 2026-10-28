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
  /// return [document] once it completes.
  void stubGetDocumentFromCollectionFuture(
    Future<Map<String, dynamic>?> document,
  ) {
    when(
      () => getDocumentFromCollection(any(), any()),
    ).thenAnswer((_) => document);
  }

  /// Stubs `getDocumentFromCollection(collectionPath, documentPath)` to
  /// throw [error].
  void stubGetDocumentFromCollectionThrows(Object error) {
    when(() => getDocumentFromCollection(any(), any())).thenThrow(error);
  }

  /// Stubs `getCollectionQuerySnapshot(collectionPath, documentIdField:)` to
  /// return [documents].
  void stubGetCollectionQuerySnapshot(List<Map<String, dynamic>> documents) {
    when(
      () => getCollectionQuerySnapshot(
        any(),
        documentIdField: any(named: 'documentIdField'),
      ),
    ).thenAnswer((_) async => documents);
  }

  /// Stubs `getCollectionQuerySnapshot(collectionPath, documentIdField:)` to
  /// throw [error].
  void stubGetCollectionQuerySnapshotThrows(Object error) {
    when(
      () => getCollectionQuerySnapshot(
        any(),
        documentIdField: any(named: 'documentIdField'),
      ),
    ).thenThrow(error);
  }

  /// Stubs `mergeDocumentInCollection(...)` to complete.
  void stubMergeDocumentInCollection() {
    when(
      () => mergeDocumentInCollection(
        collectionPath: any(named: 'collectionPath'),
        documentPath: any(named: 'documentPath'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
  }

  /// Stubs `mergeDocumentInCollection(...)` to throw [error].
  void stubMergeDocumentInCollectionThrows(Object error) {
    when(
      () => mergeDocumentInCollection(
        collectionPath: any(named: 'collectionPath'),
        documentPath: any(named: 'documentPath'),
        data: any(named: 'data'),
      ),
    ).thenThrow(error);
  }

  /// Stubs `addDocumentToCollection(...)` to complete normally.
  void stubAddDocumentToCollection() {
    when(
      () => addDocumentToCollection(
        collectionPath: any(named: 'collectionPath'),
        documentPath: any(named: 'documentPath'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
  }

  /// Stubs `addDocumentToCollection(...)` to throw [error].
  void stubAddDocumentToCollectionThrows(Object error) {
    when(
      () => addDocumentToCollection(
        collectionPath: any(named: 'collectionPath'),
        documentPath: any(named: 'documentPath'),
        data: any(named: 'data'),
      ),
    ).thenThrow(error);
  }

  /// Stubs `updateDocumentFromCollection(...)` to complete.
  void stubUpdateDocumentFromCollection() {
    when(
      () => updateDocumentFromCollection(any(), any(), any()),
    ).thenAnswer((_) async {});
  }

  /// Stubs `updateDocumentFromCollection(...)` to throw [error].
  void stubUpdateDocumentFromCollectionThrows(Object error) {
    when(
      () => updateDocumentFromCollection(any(), any(), any()),
    ).thenThrow(error);
  }
}
