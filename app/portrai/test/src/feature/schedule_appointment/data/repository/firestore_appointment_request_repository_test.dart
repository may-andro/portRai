import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/data/_data.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  group('FirestoreAppointmentRequestRepository', () {
    late MockFbFirestoreController firestoreController;
    late MockLogReporter logReporter;
    late FirestoreAppointmentRequestRepository repository;

    Map<String, dynamic> document({
      String id = 'request-1',
      Object status = 'requested',
    }) => {
      'id': id,
      'slotStart': Timestamp.fromDate(DateTime.utc(2026, 11, 3, 14)),
      'slotEnd': Timestamp.fromDate(DateTime.utc(2026, 11, 3, 14, 30)),
      'name': 'Alex Doe',
      'email': 'alex@example.com',
      'topic': 'Flutter consulting',
      'message': 'Hello',
      'locale': 'en',
      'timeZone': null,
      'status': status,
      'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 28)),
      'expiresAt': Timestamp.fromDate(DateTime.utc(2026, 12, 3)),
    };

    setUp(() {
      firestoreController = MockFbFirestoreController();
      logReporter = MockLogReporter();
      repository = FirestoreAppointmentRequestRepository(
        firestoreController,
        const ReceivedAppointmentRequestMapper(),
        logReporter,
      );
    });

    test('should read the requests from the user subcollection with their '
        'document IDs', () async {
      firestoreController.stubGetCollectionQuerySnapshot([document()]);

      final requests = await repository.getAppointmentRequests('owner-uid');

      final request = requests.single;
      expect(request.id, 'request-1');
      expect(request.slotStart.toUtc(), DateTime.utc(2026, 11, 3, 14));
      expect(request.slotEnd.toUtc(), DateTime.utc(2026, 11, 3, 14, 30));
      expect(request.name, 'Alex Doe');
      expect(request.message, 'Hello');
      expect(request.status, AppointmentRequestStatus.requested);
      verify(
        () => firestoreController.getCollectionQuerySnapshot(
          'users/owner-uid/call_requests',
          documentIdField: 'id',
        ),
      ).called(1);
    });

    test('should read an empty message when the visitor wrote none', () async {
      firestoreController.stubGetCollectionQuerySnapshot([
        document()..remove('message'),
      ]);

      final requests = await repository.getAppointmentRequests('owner-uid');

      expect(requests.single.message, isEmpty);
    });

    for (final (label, broken) in [
      ('a field has the wrong type', document(id: 'broken')..['name'] = 42),
      ('its status is unknown', document(id: 'broken', status: 'cancelled')),
    ]) {
      test(
        'should skip and log a request without its details when $label',
        () async {
          firestoreController.stubGetCollectionQuerySnapshot([
            document(),
            broken,
          ]);

          final requests = await repository.getAppointmentRequests('owner-uid');

          expect(requests.map((request) => request.id), ['request-1']);
          final message =
              verify(
                    () => logReporter.error(
                      captureAny(),
                      tag: any(named: 'tag'),
                      error: any<Object?>(named: 'error'),
                      stacktrace: any(named: 'stacktrace'),
                    ),
                  ).captured.single
                  as String;
          expect(message, contains('broken'));
          expect(message, isNot(contains('Alex')));
        },
      );
    }

    for (final (decision, status) in [
      (AppointmentDecision.accept, 'accepted'),
      (AppointmentDecision.decline, 'declined'),
    ]) {
      test('should write $status with the server time when the owner '
          'chooses ${decision.name}', () async {
        firestoreController.stubUpdateDocumentFromCollection();

        await repository.decideAppointmentRequest(
          userId: 'owner-uid',
          id: 'request-1',
          decision: decision,
        );

        final data =
            verify(
                  () => firestoreController.updateDocumentFromCollection(
                    'users/owner-uid/call_requests',
                    'request-1',
                    captureAny(),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(data.keys, unorderedEquals(['status', 'decidedAt']));
        expect(data['status'], status);
        expect(data['decidedAt'], isA<FieldValue>());
      });
    }

    for (final (firestoreException, exceptionMatcher) in [
      (
        const FirestoreDocumentNotFoundException(
          'path',
          Object(),
          StackTrace.empty,
        ),
        isA<AppointmentRequestNotFoundException>(),
      ),
      (
        const FirestorePermissionDeniedException(
          'write',
          Object(),
          StackTrace.empty,
        ),
        isA<AppointmentRequestPermissionDeniedException>(),
      ),
      (
        const FirestoreNetworkException(Object(), StackTrace.empty),
        isA<ScheduleAppointmentNetworkException>(),
      ),
      (
        const FirestoreTimeoutException('write', Object(), StackTrace.empty),
        isA<ScheduleAppointmentNetworkException>(),
      ),
      (
        const FirestoreUnknownException(Object(), StackTrace.empty),
        isA<ScheduleAppointmentUnknownException>(),
      ),
    ]) {
      test('should throw the matching exception when Firestore throws '
          '${firestoreException.runtimeType}', () async {
        firestoreController
          ..stubGetCollectionQuerySnapshotThrows(firestoreException)
          ..stubUpdateDocumentFromCollectionThrows(firestoreException);

        await expectLater(
          repository.getAppointmentRequests('owner-uid'),
          throwsA(exceptionMatcher),
        );
        await expectLater(
          repository.decideAppointmentRequest(
            userId: 'owner-uid',
            id: 'request-1',
            decision: AppointmentDecision.accept,
          ),
          throwsA(exceptionMatcher),
        );
      });
    }
  });
}
