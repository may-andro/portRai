import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/schedule_appointment/data/model/_model.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

/// Reads the requests the appointment function saves to
/// `users/{uid}/call_requests` and writes the owner's answer, which the
/// function then emails to the visitor.
/// There is no cache or bundled fallback: the data is private to the user.
@Register(as: AppointmentRequestRepository)
class FirestoreAppointmentRequestRepository
    implements AppointmentRequestRepository {
  FirestoreAppointmentRequestRepository(
    this._firestoreController,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final ReceivedAppointmentRequestMapper _mapper;
  final LogReporter _logReporter;

  static const _tag = 'FirestoreAppointmentRequestRepository';
  static const _idField = 'id';

  static String _requestsCollection(String userId) =>
      'users/$userId/call_requests';

  @override
  Future<List<ReceivedAppointmentRequestEntity>> getAppointmentRequests(
    String userId,
  ) async {
    final List<Map<String, dynamic>> documents;
    try {
      documents = await _firestoreController.getCollectionQuerySnapshot(
        _requestsCollection(userId),
        documentIdField: _idField,
      );
    } catch (error, stackTrace) {
      throw _toScheduleAppointmentException(error, stackTrace);
    }

    // One malformed request must not hide the others.
    return documents.expand((document) {
      try {
        return [
          _mapper.map(ReceivedAppointmentRequestModel.fromJson(document)),
        ];
      } catch (error, stackTrace) {
        // The error alone could quote the visitor's details, so only its
        // type is logged.
        _logReporter.error(
          'Skipping appointment request ${document[_idField]} that does not '
          'parse: ${error.runtimeType}',
          tag: _tag,
          stacktrace: stackTrace,
        );
        return const <ReceivedAppointmentRequestEntity>[];
      }
    }).toList();
  }

  @override
  Future<void> decideAppointmentRequest({
    required String userId,
    required String id,
    required AppointmentDecision decision,
  }) async {
    try {
      await _firestoreController.updateDocumentFromCollection(
        _requestsCollection(userId),
        id,
        {
          'status': decision.status.name,
          // The rules require the server time.
          'decidedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (error, stackTrace) {
      throw _toScheduleAppointmentException(error, stackTrace);
    }
  }

  static ScheduleAppointmentException _toScheduleAppointmentException(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    FirestoreDocumentNotFoundException() => AppointmentRequestNotFoundException(
      cause: error,
      stackTrace: stackTrace,
    ),
    FirestorePermissionDeniedException() =>
      AppointmentRequestPermissionDeniedException(
        cause: error,
        stackTrace: stackTrace,
      ),
    FirestoreNetworkException() || FirestoreTimeoutException() =>
      ScheduleAppointmentNetworkException(cause: error, stackTrace: stackTrace),
    _ => ScheduleAppointmentUnknownException(
      cause: error,
      stackTrace: stackTrace,
    ),
  };
}
