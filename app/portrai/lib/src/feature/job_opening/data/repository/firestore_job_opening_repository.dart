import 'package:firebase/firebase.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/job_opening/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/job_opening/data/model/_model.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

/// Reads the openings the weekly Cloud Function writes to
/// `users/{uid}/job_openings`.
/// There is no cache or bundled fallback: the data is private to the user.
@Register(as: JobOpeningRepository)
class FirestoreJobOpeningRepository implements JobOpeningRepository {
  FirestoreJobOpeningRepository(
    this._firestoreController,
    this._mapper,
    this._logReporter,
  );

  final FbFirestoreController _firestoreController;
  final JobOpeningMapper _mapper;
  final LogReporter _logReporter;

  static const _tag = 'FirestoreJobOpeningRepository';
  static const _usersCollection = 'users';
  static const _idField = 'id';

  static String _jobOpeningsCollection(String userId) =>
      '$_usersCollection/$userId/job_openings';

  @override
  Future<List<JobOpeningEntity>> getJobOpenings(String userId) async {
    final List<Map<String, dynamic>> documents;
    try {
      documents = await _firestoreController.getCollectionQuerySnapshot(
        _jobOpeningsCollection(userId),
        documentIdField: _idField,
      );
    } catch (error, stackTrace) {
      throw _toJobOpeningException(error, stackTrace);
    }

    // One malformed opening must not hide the others.
    return documents.expand((document) {
      try {
        return [_mapper.map(JobOpeningModel.fromJson(document))];
      } catch (error, stackTrace) {
        _logReporter.error(
          'Skipping job opening ${document[_idField]} that does not parse',
          tag: _tag,
          error: error,
          stacktrace: stackTrace,
        );
        return const <JobOpeningEntity>[];
      }
    }).toList();
  }

  @override
  Future<JobOpeningEntity> getJobOpening({
    required String userId,
    required String id,
  }) async {
    final Map<String, dynamic>? document;
    try {
      document = await _firestoreController.getDocumentFromCollection(
        _jobOpeningsCollection(userId),
        id,
      );
    } catch (error, stackTrace) {
      throw _toJobOpeningException(error, stackTrace);
    }
    if (document == null) {
      throw JobOpeningNotFoundException(cause: 'Job opening $id not found');
    }

    try {
      return _mapper.map(JobOpeningModel.fromJson({...document, _idField: id}));
    } catch (error, stackTrace) {
      throw JobOpeningParsingException(cause: error, stackTrace: stackTrace);
    }
  }

  static JobOpeningException _toJobOpeningException(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    FirestoreDocumentNotFoundException() => JobOpeningNotFoundException(
      cause: error,
      stackTrace: stackTrace,
    ),
    FirestorePermissionDeniedException() => JobOpeningPermissionDeniedException(
      cause: error,
      stackTrace: stackTrace,
    ),
    FirestoreNetworkException() || FirestoreTimeoutException() =>
      JobOpeningNetworkException(cause: error, stackTrace: stackTrace),
    _ => JobOpeningUnknownException(cause: error, stackTrace: stackTrace),
  };
}
