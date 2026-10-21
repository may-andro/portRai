import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/data/model/_model.dart';

void main() {
  group('FirestoreDateTimeConverter', () {
    const converter = FirestoreDateTimeConverter();
    final dateTime = DateTime.utc(2026, 10, 17, 16, 4, 29);

    test('should read the date when the value is a Firestore timestamp', () {
      expect(
        converter.fromJson(Timestamp.fromDate(dateTime)).toUtc(),
        dateTime,
      );
    });

    test('should read the date when the value is an ISO string', () {
      expect(converter.fromJson('2026-10-17T16:04:29Z'), dateTime);
    });

    test('should read the date when the value is milliseconds', () {
      expect(
        converter.fromJson(dateTime.millisecondsSinceEpoch).toUtc(),
        dateTime,
      );
    });

    test('should throw when the value is not a date', () {
      expect(() => converter.fromJson(true), throwsFormatException);
    });

    test('should write a Firestore timestamp when converting back', () {
      expect(converter.toJson(dateTime), Timestamp.fromDate(dateTime));
    });
  });
}
