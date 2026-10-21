import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const collectionPath = 'parents/parent-1/children';

  group('getCollectionQuerySnapshot', () {
    test('should add each document ID under the given field when '
        'documentIdField is set', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection(collectionPath).doc('child-1').set({
        'name': 'First child',
      });
      final controller = FbFirestoreController(firestore);

      final documents = await controller.getCollectionQuerySnapshot(
        collectionPath,
        documentIdField: 'id',
      );

      expect(documents, [
        {'name': 'First child', 'id': 'child-1'},
      ]);
    });

    test(
      'should return the data only when documentIdField is not set',
      () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection(collectionPath).doc('child-1').set({
          'name': 'First child',
        });
        final controller = FbFirestoreController(firestore);

        final documents = await controller.getCollectionQuerySnapshot(
          collectionPath,
        );

        expect(documents, [
          {'name': 'First child'},
        ]);
      },
    );
  });

  group('mergeDocumentInCollection', () {
    test('should create the document when it does not exist', () async {
      final firestore = FakeFirebaseFirestore();
      final controller = FbFirestoreController(firestore);

      await controller.mergeDocumentInCollection(
        collectionPath: 'preferences',
        documentPath: 'preference-1',
        data: {
          'settings': {'enabled': true},
        },
      );

      final snapshot = await firestore.doc('preferences/preference-1').get();
      expect(snapshot.data(), {
        'settings': {'enabled': true},
      });
    });

    test('should keep the other fields, nested ones included, when the '
        'document exists', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.doc('preferences/preference-1').set({
        'settings': {'enabled': true, 'note': 'kept'},
        'other': 'kept',
      });
      final controller = FbFirestoreController(firestore);

      await controller.mergeDocumentInCollection(
        collectionPath: 'preferences',
        documentPath: 'preference-1',
        data: {
          'settings': {'enabled': false},
        },
      );

      final snapshot = await firestore.doc('preferences/preference-1').get();
      expect(snapshot.data(), {
        'settings': {'enabled': false, 'note': 'kept'},
        'other': 'kept',
      });
    });

    test('should throw a FirestoreException when the data is empty', () {
      final controller = FbFirestoreController(FakeFirebaseFirestore());

      expect(
        () => controller.mergeDocumentInCollection(
          collectionPath: 'preferences',
          documentPath: 'preference-1',
          data: {},
        ),
        throwsA(isA<FirestoreException>()),
      );
    });
  });
}
