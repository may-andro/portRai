import 'package:core/src/extension/version_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VersionComparisonExtension', () {
    group('compareVersion', () {
      test('should return 0 when versions are equal', () {
        expect('1.2.3'.compareVersion('1.2.3'), equals(0));
      });

      test('should return negative when this version is lower', () {
        expect('1.2.3'.compareVersion('1.2.4'), lessThan(0));
        expect('1.2.3'.compareVersion('1.3.0'), lessThan(0));
        expect('1.2.3'.compareVersion('2.0.0'), lessThan(0));
      });

      test('should return positive when this version is higher', () {
        expect('1.2.4'.compareVersion('1.2.3'), greaterThan(0));
        expect('2.0.0'.compareVersion('1.9.9'), greaterThan(0));
      });

      test('should treat missing segments as zero', () {
        expect('1.2'.compareVersion('1.2.0'), equals(0));
        expect('1.2'.compareVersion('1.2.1'), lessThan(0));
        expect('1'.compareVersion('1.0.0'), equals(0));
      });

      test('should ignore non-numeric suffixes on a segment', () {
        expect('1.2.3-beta'.compareVersion('1.2.3'), equals(0));
      });
    });

    group('isLowerVersionThan', () {
      test('should return true when this version is lower', () {
        expect('1.0.0'.isLowerVersionThan('1.0.1'), isTrue);
      });

      test('should return false when this version is equal', () {
        expect('1.0.0'.isLowerVersionThan('1.0.0'), isFalse);
      });

      test('should return false when this version is higher', () {
        expect('1.0.1'.isLowerVersionThan('1.0.0'), isFalse);
      });
    });
  });
}
