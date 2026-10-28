import 'package:firebase/firebase.dart' as firebase;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/schedule_appointment/data/model/_model.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

/// Calls the appointment functions. Visitors are not signed in; the functions
/// accept only calls from the app.
@Register(as: ScheduleAppointmentRepository)
class FirebaseScheduleAppointmentRepository
    implements ScheduleAppointmentRepository {
  FirebaseScheduleAppointmentRepository(
    this._functionController,
    this._appointmentSlotsMapper,
    this._appointmentRequestMapper,
  );

  final firebase.FbFunctionController _functionController;
  final AppointmentSlotsMapper _appointmentSlotsMapper;
  final AppointmentRequestMapper _appointmentRequestMapper;

  @override
  Future<AppointmentSlotsEntity> getAppointmentSlots() async {
    try {
      final responseData = await _functionController.callFunction(
        'getCallSlots',
        requiresSignIn: false,
      );
      return _appointmentSlotsMapper.map(
        AppointmentSlotsModel.fromJson(_jsonMap(responseData)),
      );
    } catch (error, stackTrace) {
      throw _toScheduleAppointmentException(error, stackTrace);
    }
  }

  @override
  Future<String> requestAppointment(AppointmentRequestEntity request) async {
    try {
      // A fresh token for every request, so a captured call cannot be
      // replayed.
      final responseData = await _functionController.callFunction(
        'requestCall',
        parameters: _appointmentRequestMapper.map(request).toJson(),
        requiresSignIn: false,
        limitedUseAppCheckToken: true,
      );
      final requestId = _jsonMap(responseData)['requestId'];
      if (requestId is! String) {
        throw const FormatException('The response has no request ID');
      }
      return requestId;
    } catch (error, stackTrace) {
      throw _toScheduleAppointmentException(error, stackTrace);
    }
  }

  /// The platforms return maps with `Object?` keys, which JSON parsing does
  /// not take.
  static Map<String, dynamic> _jsonMap(Object? responseData) {
    if (responseData is! Map) {
      throw const FormatException('The response is not a map');
    }
    return responseData.map((key, value) => MapEntry('$key', value));
  }

  static ScheduleAppointmentException _toScheduleAppointmentException(
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ScheduleAppointmentException) return error;
    if (error is firebase.FunctionException) {
      final details = error.details;
      final reason = details is Map ? details['reason'] : null;
      return switch (reason) {
        'not_set_up' => ScheduleAppointmentNotSetUpException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'slot_taken' ||
        'slot_not_offered' => AppointmentSlotUnavailableException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'too_many_open_requests' ||
        'daily_limit' => AppointmentRequestLimitException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'invalid' => AppointmentRequestInvalidException(
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => switch (error) {
          firebase.FunctionNetworkException() ||
          firebase.FunctionTimeoutException() =>
            ScheduleAppointmentNetworkException(
              cause: error,
              stackTrace: stackTrace,
            ),
          _ => ScheduleAppointmentUnknownException(
            cause: error,
            stackTrace: stackTrace,
          ),
        },
      };
    }
    // Includes a response that does not parse.
    return ScheduleAppointmentUnknownException(
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
