import 'package:firebase/firebase.dart' as firebase;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/call_booking/data/model/_model.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

/// Calls the booking functions. Visitors are not signed in; the functions
/// accept only calls from the app.
@Register(as: CallBookingRepository)
class FirebaseCallBookingRepository implements CallBookingRepository {
  FirebaseCallBookingRepository(
    this._functionController,
    this._callSlotsMapper,
    this._callRequestMapper,
  );

  final firebase.FbFunctionController _functionController;
  final CallSlotsMapper _callSlotsMapper;
  final CallRequestMapper _callRequestMapper;

  @override
  Future<CallSlotsEntity> getCallSlots() async {
    try {
      final responseData = await _functionController.callFunction(
        'getCallSlots',
        requiresSignIn: false,
      );
      return _callSlotsMapper.map(
        CallSlotsModel.fromJson(_jsonMap(responseData)),
      );
    } catch (error, stackTrace) {
      throw _toCallBookingException(error, stackTrace);
    }
  }

  @override
  Future<String> requestCall(CallRequestEntity request) async {
    try {
      // A fresh token for every request, so a captured call cannot be
      // replayed.
      final responseData = await _functionController.callFunction(
        'requestCall',
        parameters: _callRequestMapper.map(request).toJson(),
        requiresSignIn: false,
        limitedUseAppCheckToken: true,
      );
      final requestId = _jsonMap(responseData)['requestId'];
      if (requestId is! String) {
        throw const FormatException('The response has no request ID');
      }
      return requestId;
    } catch (error, stackTrace) {
      throw _toCallBookingException(error, stackTrace);
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

  static CallBookingException _toCallBookingException(
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is CallBookingException) return error;
    if (error is firebase.FunctionException) {
      final details = error.details;
      final reason = details is Map ? details['reason'] : null;
      return switch (reason) {
        'not_set_up' => CallBookingNotSetUpException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'slot_taken' || 'slot_not_offered' => CallSlotUnavailableException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'too_many_open_requests' || 'daily_limit' => CallRequestLimitException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'invalid' => CallRequestInvalidException(
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => switch (error) {
          firebase.FunctionNetworkException() ||
          firebase.FunctionTimeoutException() => CallBookingNetworkException(
            cause: error,
            stackTrace: stackTrace,
          ),
          _ => CallBookingUnknownException(
            cause: error,
            stackTrace: stackTrace,
          ),
        },
      };
    }
    // Includes a response that does not parse.
    return CallBookingUnknownException(cause: error, stackTrace: stackTrace);
  }
}
