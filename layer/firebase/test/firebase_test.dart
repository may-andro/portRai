import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase/src/auth/fb_auth_controller.dart';
import 'package:firebase/src/firestore/fb_firestore_controller.dart';
import 'package:firebase/src/firestore/firestore_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ─── FbFirestoreController ────────────────────────────────────────────────
  group(FbFirestoreController, () {
    late FakeFirebaseFirestore fakeFirestore;
    late FbFirestoreController controller;

    const collection = 'testCollection';
    const docId = 'doc1';
    final testData = {'name': 'Alice', 'age': 30};

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      controller = FbFirestoreController(fakeFirestore);
    });

    // ── addToCollection ─────────────────────────────────────────────────────
    group('addToCollection', () {
      test('should add a document to the collection', () async {
        await controller.addToCollection(collection, testData);

        final snapshot = await fakeFirestore.collection(collection).get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Alice');
      });

      test('should throw FirestoreUnknownException for empty collection path',
          () async {
        expect(
          () => controller.addToCollection('', testData),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });

      test('should throw FirestoreUnknownException for empty data', () async {
        expect(
          () => controller.addToCollection(collection, {}),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });
    });

    // ── addDocumentToCollection ──────────────────────────────────────────────
    group('addDocumentToCollection', () {
      test('should add document with specified id', () async {
        await controller.addDocumentToCollection(
          collectionPath: collection,
          documentPath: docId,
          data: testData,
        );

        final doc =
            await fakeFirestore.collection(collection).doc(docId).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], 'Alice');
      });

      test('should throw for empty document path', () async {
        expect(
          () => controller.addDocumentToCollection(
            collectionPath: collection,
            documentPath: '',
            data: testData,
          ),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });
    });

    // ── getDocumentFromCollection ────────────────────────────────────────────
    group('getDocumentFromCollection', () {
      test('should return document data when it exists', () async {
        await fakeFirestore
            .collection(collection)
            .doc(docId)
            .set(testData);

        final result = await controller.getDocumentFromCollection(
          collection,
          docId,
        );

        expect(result, isNotNull);
        expect(result!['name'], 'Alice');
      });

      test('should throw FirestoreDocumentNotFoundException when not found',
          () async {
        expect(
          () => controller.getDocumentFromCollection(
            collection,
            'nonexistent',
          ),
          throwsA(isA<FirestoreDocumentNotFoundException>()),
        );
      });

      test('should throw for empty collection path', () async {
        expect(
          () => controller.getDocumentFromCollection('', docId),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });
    });

    // ── updateDocumentFromCollection ─────────────────────────────────────────
    group('updateDocumentFromCollection', () {
      test('should update an existing document', () async {
        await fakeFirestore
            .collection(collection)
            .doc(docId)
            .set(testData);

        await controller.updateDocumentFromCollection(
          collection,
          docId,
          {'name': 'Bob'},
        );

        final doc =
            await fakeFirestore.collection(collection).doc(docId).get();
        expect(doc.data()!['name'], 'Bob');
      });

      test(
          'should throw FirestoreDocumentNotFoundException when doc not found',
          () async {
        expect(
          () => controller.updateDocumentFromCollection(
            collection,
            'nonexistent',
            {'name': 'Bob'},
          ),
          throwsA(isA<FirestoreDocumentNotFoundException>()),
        );
      });
    });

    // ── deleteDocumentFromCollection ─────────────────────────────────────────
    group('deleteDocumentFromCollection', () {
      test('should delete an existing document', () async {
        await fakeFirestore
            .collection(collection)
            .doc(docId)
            .set(testData);

        await controller.deleteDocumentFromCollection(
          collectionPath: collection,
          documentPath: docId,
        );

        final doc =
            await fakeFirestore.collection(collection).doc(docId).get();
        expect(doc.exists, isFalse);
      });

      test(
          'should throw FirestoreDocumentNotFoundException when doc not found',
          () async {
        expect(
          () => controller.deleteDocumentFromCollection(
            collectionPath: collection,
            documentPath: 'nonexistent',
          ),
          throwsA(isA<FirestoreDocumentNotFoundException>()),
        );
      });
    });

    // ── getCollectionQuerySnapshot ───────────────────────────────────────────
    group('getCollectionQuerySnapshot', () {
      test('should return all documents from collection', () async {
        await fakeFirestore
            .collection(collection)
            .doc('a')
            .set({'name': 'Alice', 'age': 30});
        await fakeFirestore
            .collection(collection)
            .doc('b')
            .set({'name': 'Bob', 'age': 25});

        final result = await controller.getCollectionQuerySnapshot(collection);

        expect(result.length, 2);
      });

      test('should filter by field equality', () async {
        await fakeFirestore
            .collection(collection)
            .doc('a')
            .set({'name': 'Alice', 'age': 30});
        await fakeFirestore
            .collection(collection)
            .doc('b')
            .set({'name': 'Bob', 'age': 25});

        final result = await controller.getCollectionQuerySnapshot(
          collection,
          field: 'name',
          isEqualTo: 'Alice',
        );

        expect(result.length, 1);
        expect(result.first['name'], 'Alice');
      });

      test('should throw for invalid limit', () async {
        expect(
          () => controller.getCollectionQuerySnapshot(collection, limit: 0),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });
    });

    // ── batchUpdateDocuments ─────────────────────────────────────────────────
    group('batchUpdateDocuments', () {
      test('should update multiple documents in a batch', () async {
        await fakeFirestore
            .collection(collection)
            .doc('a')
            .set({'name': 'Alice'});
        await fakeFirestore
            .collection(collection)
            .doc('b')
            .set({'name': 'Bob'});

        await controller.batchUpdateDocuments(collection, [
          {'documentPath': 'a', 'data': {'name': 'Alice Updated'}},
          {'documentPath': 'b', 'data': {'name': 'Bob Updated'}},
        ]);

        final docA =
            await fakeFirestore.collection(collection).doc('a').get();
        final docB =
            await fakeFirestore.collection(collection).doc('b').get();
        expect(docA.data()!['name'], 'Alice Updated');
        expect(docB.data()!['name'], 'Bob Updated');
      });

      test('should throw for empty updates list', () async {
        expect(
          () => controller.batchUpdateDocuments(collection, []),
          throwsA(isA<FirestoreUnknownException>()),
        );
      });

      test('should throw when a document in the batch does not exist',
          () async {
        expect(
          () => controller.batchUpdateDocuments(collection, [
            {'documentPath': 'nonexistent', 'data': {'name': 'X'}},
          ]),
          throwsA(isA<FirestoreDocumentNotFoundException>()),
        );
      });
    });
  });

  // ─── handleFirestoreException ──────────────────────────────────────────────
  group('handleFirestoreException', () {
    test('should return FirestoreDocumentNotFoundException for not-found code',
        () {
      final error = FirebaseException(plugin: 'firestore', code: 'not-found');
      final result =
          handleFirestoreException(error, StackTrace.current, 'op');
      expect(result, isA<FirestoreDocumentNotFoundException>());
    });

    test('should return FirestorePermissionDeniedException for permission-denied',
        () {
      final error =
          FirebaseException(plugin: 'firestore', code: 'permission-denied');
      final result =
          handleFirestoreException(error, StackTrace.current, 'op');
      expect(result, isA<FirestorePermissionDeniedException>());
    });

    test('should return FirestoreTimeoutException for unavailable', () {
      final error =
          FirebaseException(plugin: 'firestore', code: 'unavailable');
      final result =
          handleFirestoreException(error, StackTrace.current, 'op');
      expect(result, isA<FirestoreTimeoutException>());
    });

    test('should return FirestoreQuotaExceededException for resource-exhausted',
        () {
      final error = FirebaseException(
        plugin: 'firestore',
        code: 'resource-exhausted',
      );
      final result =
          handleFirestoreException(error, StackTrace.current, 'op');
      expect(result, isA<FirestoreQuotaExceededException>());
    });

    test('should return FirestoreUnknownException for unrecognised code', () {
      final error =
          FirebaseException(plugin: 'firestore', code: 'some-unknown-code');
      final result =
          handleFirestoreException(error, StackTrace.current, 'op');
      expect(result, isA<FirestoreUnknownException>());
    });

    test('should return FirestoreNetworkException for network-related message',
        () {
      final result = handleFirestoreException(
        Exception('network connection lost'),
        StackTrace.current,
        'op',
      );
      expect(result, isA<FirestoreNetworkException>());
    });

    test('should return FirestoreUnknownException for generic exceptions', () {
      final result = handleFirestoreException(
        Exception('something else'),
        StackTrace.current,
        'op',
      );
      expect(result, isA<FirestoreUnknownException>());
    });
  });

  // ─── FbAuthController.extractResetCodeFromUrl ─────────────────────────────
  group('FbAuthController.extractResetCodeFromUrl', () {
    test('should extract oobCode from valid password reset URL', () {
      const url =
          'https://app.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=ABC123&apiKey=key';
      expect(FbAuthController.extractResetCodeFromUrl(url), 'ABC123');
    });

    test('should return null for non-auth-action URL', () {
      expect(
        FbAuthController.extractResetCodeFromUrl('https://example.com/other'),
        isNull,
      );
    });

    test('should return null when mode is not resetPassword', () {
      const url =
          'https://app.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=XYZ';
      expect(FbAuthController.extractResetCodeFromUrl(url), isNull);
    });

    test('should return null for empty string', () {
      expect(FbAuthController.extractResetCodeFromUrl(''), isNull);
    });

    test('should return null when oobCode is absent', () {
      const url =
          'https://app.firebaseapp.com/__/auth/action?mode=resetPassword';
      expect(FbAuthController.extractResetCodeFromUrl(url), isNull);
    });
  });
}
