import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const collectionPath = 'users/owner-uid/job_openings';

  group('getCollectionQuerySnapshot', () {
    test('should add each document ID under the given field when '
        'documentIdField is set', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection(collectionPath).doc('job-1').set({
        'title': 'Flutter Developer',
      });
      final controller = FbFirestoreController(firestore);

      final documents = await controller.getCollectionQuerySnapshot(
        collectionPath,
        documentIdField: 'id',
      );

      expect(documents, [
        {'title': 'Flutter Developer', 'id': 'job-1'},
      ]);
    });

    test(
      'should return the data only when documentIdField is not set',
      () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection(collectionPath).doc('job-1').set({
          'title': 'Flutter Developer',
        });
        final controller = FbFirestoreController(firestore);

        final documents = await controller.getCollectionQuerySnapshot(
          collectionPath,
        );

        expect(documents, [
          {'title': 'Flutter Developer'},
        ]);
      },
    );
  });

  group('mergeDocumentInCollection', () {
    test('should create the document when it does not exist', () async {
      final firestore = FakeFirebaseFirestore();
      final controller = FbFirestoreController(firestore);

      await controller.mergeDocumentInCollection(
        collectionPath: 'users',
        documentPath: 'owner-uid',
        data: {
          'jobSearch': {'enabled': true},
        },
      );

      final snapshot = await firestore.doc('users/owner-uid').get();
      expect(snapshot.data(), {
        'jobSearch': {'enabled': true},
      });
    });

    test('should keep the other fields, nested ones included, when the '
        'document exists', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.doc('users/owner-uid').set({
        'jobSearch': {'enabled': true, 'note': 'kept'},
        'other': 'kept',
      });
      final controller = FbFirestoreController(firestore);

      await controller.mergeDocumentInCollection(
        collectionPath: 'users',
        documentPath: 'owner-uid',
        data: {
          'jobSearch': {'enabled': false},
        },
      );

      final snapshot = await firestore.doc('users/owner-uid').get();
      expect(snapshot.data(), {
        'jobSearch': {'enabled': false, 'note': 'kept'},
        'other': 'kept',
      });
    });

    test('should throw a FirestoreException when the data is empty', () {
      final controller = FbFirestoreController(FakeFirebaseFirestore());

      expect(
        () => controller.mergeDocumentInCollection(
          collectionPath: 'users',
          documentPath: 'owner-uid',
          data: {},
        ),
        throwsA(isA<FirestoreException>()),
      );
    });
  });
}
