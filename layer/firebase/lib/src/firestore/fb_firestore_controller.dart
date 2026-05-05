import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/src/firestore/firestore_exception.dart';

class FbFirestoreController {
  FbFirestoreController(this._firebaseFirestore);

  final FirebaseFirestore _firebaseFirestore;

  Future<void> addToCollection(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (data.isEmpty) {
        throw ArgumentError('Data cannot be empty');
      }

      await _firebaseFirestore.collection(collectionPath).add(data);
    } catch (error, stackTrace) {
      throw handleFirestoreException(
        error,
        stackTrace,
        'adding document to collection: $collectionPath',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCollectionQuerySnapshot(
    String collectionPath, {
    String? field,
    Object? isEqualTo,
    Object? isLessThan,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? isNotEqualTo,
    bool? descending,
    String? orderBy,
    int? limit,
    String? startAfterDocumentId,
  }) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }

      if (limit != null && limit <= 0) {
        throw ArgumentError('Limit must be greater than 0');
      }

      Query<Map<String, dynamic>> query = _firebaseFirestore.collection(
        collectionPath,
      );

      // Add filtering if a field and condition are provided
      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isGreaterThanOrEqualTo != null) {
          query = query.where(
            field,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          );
        }
        if (isNotEqualTo != null) {
          query = query.where(field, isNotEqualTo: isNotEqualTo);
        }
      }

      // Add ordering if specified
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      // Add limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      // Add startAfterDocumentId if specified
      if (startAfterDocumentId != null) {
        final docSnapshot = await _firebaseFirestore
            .collection(collectionPath)
            .doc(startAfterDocumentId)
            .get();
        if (docSnapshot.exists) {
          query = query.startAfterDocument(docSnapshot);
        } else {
          throw FirestoreDocumentNotFoundException(
            '$collectionPath/$startAfterDocumentId',
            Exception('Start after document not found'),
            StackTrace.current,
          );
        }
      }

      final queryData = await query.get();
      final snapshots = queryData.docs.where((doc) => doc.exists);

      return snapshots.map((snapshot) => snapshot.data()).toList();
    } catch (error, stackTrace) {
      if (error is FirestoreException) {
        rethrow;
      }
      throw handleFirestoreException(
        error,
        stackTrace,
        'querying collection: $collectionPath',
      );
    }
  }

  Future<void> addDocumentToCollection({
    required String collectionPath,
    required String documentPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (documentPath.isEmpty) {
        throw ArgumentError('Document path cannot be empty');
      }
      if (data.isEmpty) {
        throw ArgumentError('Data cannot be empty');
      }

      await _firebaseFirestore
          .collection(collectionPath)
          .doc(documentPath)
          .set(data);
    } catch (error, stackTrace) {
      throw handleFirestoreException(
        error,
        stackTrace,
        'adding document to collection: $collectionPath/$documentPath',
      );
    }
  }

  Future<void> deleteDocumentFromCollection({
    required String collectionPath,
    required String documentPath,
  }) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (documentPath.isEmpty) {
        throw ArgumentError('Document path cannot be empty');
      }

      // Check if document exists before deletion
      final docRef = _firebaseFirestore
          .collection(collectionPath)
          .doc(documentPath);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw FirestoreDocumentNotFoundException(
          '$collectionPath/$documentPath',
          Exception('Document not found for deletion'),
          StackTrace.current,
        );
      }

      await docRef.delete();
    } catch (error, stackTrace) {
      if (error is FirestoreException) {
        rethrow;
      }
      throw handleFirestoreException(
        error,
        stackTrace,
        'deleting document from collection: $collectionPath/$documentPath',
      );
    }
  }

  Future<Map<String, dynamic>?> getDocumentFromCollection(
    String collectionPath,
    String documentPath,
  ) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (documentPath.isEmpty) {
        throw ArgumentError('Document path cannot be empty');
      }

      final snapshot = await _firebaseFirestore
          .collection(collectionPath)
          .doc(documentPath)
          .get();

      if (!snapshot.exists) {
        throw FirestoreDocumentNotFoundException(
          '$collectionPath/$documentPath',
          Exception('Document not found'),
          StackTrace.current,
        );
      }

      final data = snapshot.data();
      if (data == null) {
        throw FirestoreInvalidDataException(
          '$collectionPath/$documentPath',
          Exception('Document data is null'),
          StackTrace.current,
        );
      }

      return data;
    } catch (error, stackTrace) {
      if (error is FirestoreException) {
        rethrow;
      }
      throw handleFirestoreException(
        error,
        stackTrace,
        'getting document from collection: $collectionPath/$documentPath',
      );
    }
  }

  Future<void> updateDocumentFromCollection(
    String collectionPath,
    String documentPath,
    Map<String, dynamic> data,
  ) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (documentPath.isEmpty) {
        throw ArgumentError('Document path cannot be empty');
      }
      if (data.isEmpty) {
        throw ArgumentError('Data cannot be empty');
      }

      // Check if document exists before update
      final docRef = _firebaseFirestore
          .collection(collectionPath)
          .doc(documentPath);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw FirestoreDocumentNotFoundException(
          '$collectionPath/$documentPath',
          Exception('Document not found for update'),
          StackTrace.current,
        );
      }

      await docRef.update(data);
    } catch (error, stackTrace) {
      if (error is FirestoreException) {
        rethrow;
      }
      throw handleFirestoreException(
        error,
        stackTrace,
        'updating document in collection: $collectionPath/$documentPath',
      );
    }
  }

  Future<void> batchUpdateDocuments(
    String collectionPath,
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      if (collectionPath.isEmpty) {
        throw ArgumentError('Collection path cannot be empty');
      }
      if (updates.isEmpty) {
        throw ArgumentError('Updates list cannot be empty');
      }

      // Validate all updates before starting batch
      for (int i = 0; i < updates.length; i++) {
        final update = updates[i];
        if (!update.containsKey('documentPath')) {
          throw ArgumentError('Update at index $i missing documentPath');
        }
        if (!update.containsKey('data')) {
          throw ArgumentError('Update at index $i missing data');
        }
        if (update['documentPath'] is! String ||
            (update['documentPath'] as String).isEmpty) {
          throw ArgumentError('Invalid documentPath at index $i');
        }
        if (update['data'] is! Map<String, dynamic> ||
            (update['data'] as Map<String, dynamic>).isEmpty) {
          throw ArgumentError('Invalid data at index $i');
        }
      }

      final batch = _firebaseFirestore.batch();

      // Check if all documents exist before batch operation
      for (final update in updates) {
        final docPath = update['documentPath'] as String;
        final docRef = _firebaseFirestore
            .collection(collectionPath)
            .doc(docPath);

        final docSnapshot = await docRef.get();
        if (!docSnapshot.exists) {
          throw FirestoreDocumentNotFoundException(
            '$collectionPath/$docPath',
            Exception('Document not found for batch update'),
            StackTrace.current,
          );
        }

        batch.update(docRef, update['data'] as Map<String, dynamic>);
      }

      await batch.commit();
    } catch (error, stackTrace) {
      if (error is FirestoreException) {
        rethrow;
      }
      throw handleFirestoreException(
        error,
        stackTrace,
        'batch updating documents in collection: $collectionPath',
      );
    }
  }
}
