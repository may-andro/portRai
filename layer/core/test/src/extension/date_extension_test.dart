import 'package:core/src/extension/date_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeFormatting Extension', () {
    late DateTime testDate;
    late DateTime testDateWithTime;
    late DateTime newYearDate;
    late DateTime endOfYearDate;

    setUp(() {
      // October 15, 2023, 14:30
      testDate = DateTime(2023, 10, 15, 14, 30);
      // January 1, 2024, 09:15
      testDateWithTime = DateTime(2024, 1, 1, 9, 15);
      // New Year's Day 2023
      newYearDate = DateTime(2023);
      // December 31, 2023
      endOfYearDate = DateTime(2023, 12, 31);
    });

    group('toFormattedDate', () {
      test('should format date as yyyy-MM-dd', () {
        expect(testDate.toFormattedDate, equals('2023-10-15'));
        expect(testDateWithTime.toFormattedDate, equals('2024-01-01'));
        expect(newYearDate.toFormattedDate, equals('2023-01-01'));
        expect(endOfYearDate.toFormattedDate, equals('2023-12-31'));
      });

      test('should handle single digit months and days correctly', () {
        final singleDigitDate = DateTime(2023, 3, 5);
        expect(singleDigitDate.toFormattedDate, equals('2023-03-05'));
      });
    });

    group('toFormattedDateTime', () {
      test('should format date and time as dd MMM yyyy, hh:mm a', () {
        expect(testDate.toFormattedDateTime, equals('15 Oct 2023, 02:30 PM'));
        expect(
          testDateWithTime.toFormattedDateTime,
          equals('01 Jan 2024, 09:15 AM'),
        );
      });

      test('should handle midnight and noon correctly', () {
        final midnight = DateTime(2023, 6, 15);
        final noon = DateTime(2023, 6, 15, 12);

        expect(midnight.toFormattedDateTime, equals('15 Jun 2023, 12:00 AM'));
        expect(noon.toFormattedDateTime, equals('15 Jun 2023, 12:00 PM'));
      });
    });

    group('toFullDateTime', () {
      test('should format as EEEE, MMMM d, yyyy H:m', () {
        // Note: Sunday, October 15, 2023 14:30
        expect(
          testDate.toFullDateTime,
          equals('Sunday, October 15, 2023 14:30'),
        );
        expect(
          testDateWithTime.toFullDateTime,
          equals('Monday, January 1, 2024 9:15'),
        );
      });

      test('should handle different days of the week', () {
        final monday = DateTime(2023, 10, 16, 10, 45); // Monday
        expect(monday.toFullDateTime, equals('Monday, October 16, 2023 10:45'));
      });
    });

    group('toFullDateWithoutTime', () {
      test('should format as EEEE, MMMM d, yyyy without time', () {
        expect(
          testDate.toFullDateWithoutTime,
          equals('Sunday, October 15, 2023'),
        );
        expect(
          testDateWithTime.toFullDateWithoutTime,
          equals('Monday, January 1, 2024'),
        );
        expect(
          newYearDate.toFullDateWithoutTime,
          equals('Sunday, January 1, 2023'),
        );
      });
    });

    group('toMonthAndYear', () {
      test('should format as MMMM, yyyy', () {
        expect(testDate.toMonthAndYear, equals('October, 2023'));
        expect(testDateWithTime.toMonthAndYear, equals('January, 2024'));
        expect(newYearDate.toMonthAndYear, equals('January, 2023'));
      });

      test('should handle different months correctly', () {
        final februaryDate = DateTime(2023, 2, 14);
        final decemberDate = DateTime(2023, 12, 25);

        expect(februaryDate.toMonthAndYear, equals('February, 2023'));
        expect(decemberDate.toMonthAndYear, equals('December, 2023'));
      });
    });

    group('weekNumber', () {
      test('should calculate week number correctly for various dates', () {
        // January 1, 2023 (Sunday) should be week 52 of 2022/week 1 of 2023
        // ISO week numbering can place Jan 1 in the previous year's last week
        expect(newYearDate.weekNumber, equals(52));

        // January 2, 2023 (Monday) should be week 1
        final jan2 = DateTime(2023, 1, 2);
        expect(jan2.weekNumber, equals(1));

        // January 9, 2023 (Monday) should be week 2
        final jan9 = DateTime(2023, 1, 9);
        expect(jan9.weekNumber, equals(2));
      });

      test('should handle end of year week numbers', () {
        // December 31, 2023 should be week 52
        expect(endOfYearDate.weekNumber, equals(52));
      });

      test('should handle mid-year dates', () {
        // July 4, 2023 (Tuesday) - week 27
        final july4 = DateTime(2023, 7, 4);
        expect(july4.weekNumber, equals(27));
      });

      test('should handle leap year correctly', () {
        // February 29, 2024 (leap year)
        final leapDay = DateTime(2024, 2, 29);
        expect(leapDay.weekNumber, equals(9));
      });
    });
  });

  group('StringDateFormatting Extension', () {
    group('toFormattedDate', () {
      test('should parse yyyy-MM-dd format correctly', () {
        final result = '2023-10-15'.toFormattedDate;
        expect(result.year, equals(2023));
        expect(result.month, equals(10));
        expect(result.day, equals(15));
      });

      test('should handle edge dates', () {
        final newYear = '2023-01-01'.toFormattedDate;
        final endOfYear = '2023-12-31'.toFormattedDate;

        expect(newYear.month, equals(1));
        expect(newYear.day, equals(1));
        expect(endOfYear.month, equals(12));
        expect(endOfYear.day, equals(31));
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => 'not-a-date-at-all'.toFormattedDate,
          throwsFormatException,
        );
        expect(() => ''.toFormattedDate, throwsFormatException);
        expect(() => 'abc-def-ghij'.toFormattedDate, throwsFormatException);
      });
    });

    group('toFormattedDateTime', () {
      test('should parse dd MMM yyyy, hh:mm a format correctly', () {
        final result = '15 Oct 2023, 02:30 PM'.toFormattedDateTime;
        expect(result.year, equals(2023));
        expect(result.month, equals(10));
        expect(result.day, equals(15));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
      });

      test('should handle AM times correctly', () {
        final result = '01 Jan 2024, 09:15 AM'.toFormattedDateTime;
        expect(result.hour, equals(9));
        expect(result.minute, equals(15));
      });

      test('should handle midnight and noon', () {
        final midnight = '01 Jan 2024, 12:00 AM'.toFormattedDateTime;
        final noon = '01 Jan 2024, 12:00 PM'.toFormattedDateTime;

        expect(midnight.hour, equals(0));
        expect(noon.hour, equals(12));
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => 'invalid datetime'.toFormattedDateTime,
          throwsFormatException,
        );
        expect(
          () => '2023-10-15 14:30'.toFormattedDateTime,
          throwsFormatException,
        );
      });
    });

    group('toFullDateTime', () {
      test('should parse EEEE, MMMM d, yyyy H:m format correctly', () {
        final result = 'Sunday, October 15, 2023 14:30'.toFullDateTime;
        expect(result.year, equals(2023));
        expect(result.month, equals(10));
        expect(result.day, equals(15));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
      });

      test('should handle different weekdays', () {
        final result = 'Monday, January 1, 2024 9:15'.toFullDateTime;
        expect(result.year, equals(2024));
        expect(result.month, equals(1));
        expect(result.day, equals(1));
        expect(result.hour, equals(9));
        expect(result.minute, equals(15));
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => 'Invalid full datetime'.toFullDateTime,
          throwsFormatException,
        );
        expect(
          () => 'Sunday, October 15, 2023'.toFullDateTime,
          throwsFormatException,
        );
      });
    });
  });

  group('Integration Tests', () {
    test(
      'should maintain consistency between DateTime and String extensions',
      () {
        final originalDate = DateTime(2023, 10, 15, 14, 30);

        // Test toFormattedDate round trip
        final formattedDateString = originalDate.toFormattedDate;
        final parsedDate = formattedDateString.toFormattedDate;
        expect(parsedDate.year, equals(originalDate.year));
        expect(parsedDate.month, equals(originalDate.month));
        expect(parsedDate.day, equals(originalDate.day));
      },
    );

    test('should handle edge cases for week number calculation', () {
      // Test various edge cases for week numbers
      final dates = [
        DateTime(2023), // Week 52 (of previous year)
        DateTime(2023, 1, 8), // Week 2
        DateTime(2023, 6, 15), // Mid-year
        DateTime(2023, 12, 31), // End of year
      ];

      for (final date in dates) {
        final weekNum = date.weekNumber;
        expect(weekNum, greaterThan(0));
        expect(weekNum, lessThanOrEqualTo(53));
      }
    });
  });
}
