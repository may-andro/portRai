import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/data/_data.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  group('FirestoreJobOpeningRepository', () {
    late MockFbFirestoreController firestoreController;
    late MockLogReporter logReporter;
    late FirestoreJobOpeningRepository repository;

    Map<String, dynamic> document({String id = 'job-1'}) => {
      'id': id,
      'sourceName': 'Remotive',
      'title': 'Senior Flutter Developer',
      'company': 'Acme',
      'url': 'https://remotive.com/remote-jobs/1',
      'description': 'Build apps.',
      'score': 82,
      'publishedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 17)),
      'fetchedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 19)),
    };

    setUp(() {
      firestoreController = MockFbFirestoreController();
      logReporter = MockLogReporter();
      repository = FirestoreJobOpeningRepository(
        firestoreController,
        const JobOpeningMapper(),
        logReporter,
      );
    });

    test('should read the openings from the user subcollection with their '
        'document IDs', () async {
      firestoreController.stubGetCollectionQuerySnapshot([document()]);

      final jobOpenings = await repository.getJobOpenings('owner-uid');

      expect(jobOpenings.single.id, 'job-1');
      verify(
        () => firestoreController.getCollectionQuerySnapshot(
          'users/owner-uid/job_openings',
          documentIdField: 'id',
        ),
      ).called(1);
    });

    test('should skip and log an opening when it does not parse', () async {
      firestoreController.stubGetCollectionQuerySnapshot([
        document(),
        {'id': 'broken', 'title': 42},
      ]);

      final jobOpenings = await repository.getJobOpenings('owner-uid');

      expect(jobOpenings.map((jobOpening) => jobOpening.id), ['job-1']);
      verify(
        () => logReporter.error(
          any(),
          tag: any(named: 'tag'),
          error: any(named: 'error'),
          stacktrace: any(named: 'stacktrace'),
        ),
      ).called(1);
    });

    for (final (firestoreException, exceptionMatcher) in [
      (
        FirestorePermissionDeniedException('read', Object(), StackTrace.empty),
        isA<JobOpeningPermissionDeniedException>(),
      ),
      (
        FirestoreNetworkException(Object(), StackTrace.empty),
        isA<JobOpeningNetworkException>(),
      ),
      (
        FirestoreTimeoutException('read', Object(), StackTrace.empty),
        isA<JobOpeningNetworkException>(),
      ),
      (
        FirestoreUnknownException(Object(), StackTrace.empty),
        isA<JobOpeningUnknownException>(),
      ),
    ]) {
      test('should throw the matching exception when Firestore throws '
          '${firestoreException.runtimeType}', () async {
        firestoreController.stubGetCollectionQuerySnapshotThrows(
          firestoreException,
        );

        await expectLater(
          repository.getJobOpenings('owner-uid'),
          throwsA(exceptionMatcher),
        );
      });
    }

    test('should read one opening by its document ID', () async {
      firestoreController.stubGetDocumentFromCollection(
        document()..remove('id'),
      );

      final jobOpening = await repository.getJobOpening(
        userId: 'owner-uid',
        id: 'job-1',
      );

      expect(jobOpening.id, 'job-1');
      verify(
        () => firestoreController.getDocumentFromCollection(
          'users/owner-uid/job_openings',
          'job-1',
        ),
      ).called(1);
    });

    test('should throw not found when the opening does not exist', () async {
      firestoreController.stubGetDocumentFromCollectionThrows(
        FirestoreDocumentNotFoundException('path', Object(), StackTrace.empty),
      );

      await expectLater(
        repository.getJobOpening(userId: 'owner-uid', id: 'job-1'),
        throwsA(isA<JobOpeningNotFoundException>()),
      );
    });

    test(
      'should report job search on when the user document enables it',
      () async {
        firestoreController.stubGetDocumentFromCollection({
          'jobSearch': {'enabled': true},
        });

        expect(await repository.isJobSearchEnabled('owner-uid'), isTrue);
      },
    );

    test(
      'should report job search off when the user has no document',
      () async {
        firestoreController.stubGetDocumentFromCollectionThrows(
          FirestoreDocumentNotFoundException(
            'path',
            Object(),
            StackTrace.empty,
          ),
        );

        expect(await repository.isJobSearchEnabled('owner-uid'), isFalse);
      },
    );

    test('should report job search off when the document has no job search '
        'map', () async {
      firestoreController.stubGetDocumentFromCollection({'other': 'value'});

      expect(await repository.isJobSearchEnabled('owner-uid'), isFalse);
    });

    test('should merge the setting with a server timestamp when job search '
        'changes', () async {
      firestoreController.stubMergeDocumentInCollection();

      await repository.setJobSearchEnabled(
        userId: 'owner-uid',
        isEnabled: true,
      );

      final data =
          verify(
                () => firestoreController.mergeDocumentInCollection(
                  collectionPath: 'users',
                  documentPath: 'owner-uid',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      final jobSearch = data['jobSearch'] as Map<String, dynamic>;
      expect(jobSearch['enabled'], isTrue);
      expect(jobSearch['updatedAt'], FieldValue.serverTimestamp());
      expect(data.keys, ['jobSearch']);
    });

    test(
      'should throw permission denied when the rules refuse the write',
      () async {
        firestoreController.stubMergeDocumentInCollectionThrows(
          FirestorePermissionDeniedException(
            'write',
            Object(),
            StackTrace.empty,
          ),
        );

        await expectLater(
          repository.setJobSearchEnabled(userId: 'owner-uid', isEnabled: false),
          throwsA(isA<JobOpeningPermissionDeniedException>()),
        );
      },
    );
  });
}
