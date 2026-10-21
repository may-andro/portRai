import 'package:firebase/firebase.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads Firestore timestamps, which arrive as [Timestamp] rather than JSON
/// values, and writes dates back as [Timestamp].
class FirestoreDateTimeConverter implements JsonConverter<DateTime, Object> {
  const FirestoreDateTimeConverter();

  @override
  DateTime fromJson(Object json) => switch (json) {
    Timestamp() => json.toDate(),
    DateTime() => json,
    String() => DateTime.parse(json),
    int() => DateTime.fromMillisecondsSinceEpoch(json),
    _ => throw FormatException('Not a Firestore timestamp: $json'),
  };

  @override
  Object toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
