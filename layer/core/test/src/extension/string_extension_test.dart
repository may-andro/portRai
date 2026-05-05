import 'package:core/src/extension/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringMapper extension', () {
    group('capitalize', () {
      test('should return empty string when string is empty', () {
        const input = '';
        expect(input.capitalize, equals(''));
      });

      test('should return uppercase when string has single character', () {
        const input = 'a';
        expect(input.capitalize, equals('A'));
      });

      test(
        'should capitalize first letter when string has multiple characters',
        () {
          const input = 'hello';
          expect(input.capitalize, equals('Hello'));
        },
      );

      test('should capitalize first letter and keep rest unchanged', () {
        const input = 'hELLO wORLD';
        expect(input.capitalize, equals('HELLO wORLD'));
      });

      test('should handle already capitalized string', () {
        const input = 'Hello World';
        expect(input.capitalize, equals('Hello World'));
      });

      test('should handle string with numbers and special characters', () {
        const input = '123abc';
        expect(input.capitalize, equals('123abc'));
      });

      test('should handle string starting with special character', () {
        const input = '@hello';
        expect(input.capitalize, equals('@hello'));
      });
    });

    group('isBlank', () {
      test('should return true for empty string', () {
        const input = '';
        expect(input.isBlank, isTrue);
      });

      test('should return true for string with only spaces', () {
        const input = '   ';
        expect(input.isBlank, isTrue);
      });

      test('should return true for string with only tabs', () {
        const input = '\t\t';
        expect(input.isBlank, isTrue);
      });

      test('should return true for string with mixed whitespace', () {
        const input = ' \t \n ';
        expect(input.isBlank, isTrue);
      });

      test('should return false for string with content', () {
        const input = 'hello';
        expect(input.isBlank, isFalse);
      });

      test(
        'should return false for string with content and leading spaces',
        () {
          const input = '  hello';
          expect(input.isBlank, isFalse);
        },
      );

      test(
        'should return false for string with content and trailing spaces',
        () {
          const input = 'hello  ';
          expect(input.isBlank, isFalse);
        },
      );
    });

    group('isNotBlank', () {
      test('should return false for empty string', () {
        const input = '';
        expect(input.isNotBlank, isFalse);
      });

      test('should return false for string with only spaces', () {
        const input = '   ';
        expect(input.isNotBlank, isFalse);
      });

      test('should return true for string with content', () {
        const input = 'hello';
        expect(input.isNotBlank, isTrue);
      });

      test('should return true for string with content and spaces', () {
        const input = '  hello world  ';
        expect(input.isNotBlank, isTrue);
      });
    });
  });

  group('NullableStringIsNullOrEmptyExtension', () {
    group('isNull', () {
      test('should return true when string is null', () {
        String? input;
        expect(input.isNull, isTrue);
      });

      test('should return false when string is not null', () {
        const String input = '';
        expect(input.isNull, isFalse);
      });

      test('should return false when string has content', () {
        const String input = 'hello';
        expect(input.isNull, isFalse);
      });
    });

    group('isNonNull', () {
      test('should return false when string is null', () {
        String? input;
        expect(input.isNonNull, isFalse);
      });

      test('should return true when string is not null', () {
        const String input = '';
        expect(input.isNonNull, isTrue);
      });

      test('should return true when string has content', () {
        const String input = 'hello';
        expect(input.isNonNull, isTrue);
      });
    });

    group('isNullOrEmpty', () {
      test('should return true when string is null', () {
        String? input;
        expect(input.isNullOrEmpty, isTrue);
      });

      test('should return true when string is empty', () {
        const String input = '';
        expect(input.isNullOrEmpty, isTrue);
      });

      test('should return false when string has content', () {
        const String input = 'hello';
        expect(input.isNullOrEmpty, isFalse);
      });

      test('should return false when string has only spaces', () {
        const String input = '   ';
        expect(input.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullOrEmpty', () {
      test('should return false when string is null', () {
        String? input;
        expect(input.isNotNullOrEmpty, isFalse);
      });

      test('should return false when string is empty', () {
        const String input = '';
        expect(input.isNotNullOrEmpty, isFalse);
      });

      test('should return true when string has content', () {
        const String input = 'hello';
        expect(input.isNotNullOrEmpty, isTrue);
      });

      test('should return true when string has only spaces', () {
        const String input = '   ';
        expect(input.isNotNullOrEmpty, isTrue);
      });
    });

    group('isNullOrBlank', () {
      test('should return true when string is null', () {
        String? input;
        expect(input.isNullOrBlank, isTrue);
      });

      test('should return true when string is empty', () {
        const String input = '';
        expect(input.isNullOrBlank, isTrue);
      });

      test('should return true when string has only spaces', () {
        const String input = '   ';
        expect(input.isNullOrBlank, isTrue);
      });

      test('should return true when string has only tabs', () {
        const String input = '\t\t';
        expect(input.isNullOrBlank, isTrue);
      });

      test('should return false when string has content', () {
        const String input = 'hello';
        expect(input.isNullOrBlank, isFalse);
      });

      test('should return false when string has content with spaces', () {
        const String input = '  hello  ';
        expect(input.isNullOrBlank, isFalse);
      });
    });

    group('isNotNullOrBlank', () {
      test('should return false when string is null', () {
        String? input;
        expect(input.isNotNullOrBlank, isFalse);
      });

      test('should return false when string is empty', () {
        const String input = '';
        expect(input.isNotNullOrBlank, isFalse);
      });

      test('should return false when string has only spaces', () {
        const String input = '   ';
        expect(input.isNotNullOrBlank, isFalse);
      });

      test('should return true when string has content', () {
        const String input = 'hello';
        expect(input.isNotNullOrBlank, isTrue);
      });

      test('should return true when string has content with spaces', () {
        const String input = '  hello world  ';
        expect(input.isNotNullOrBlank, isTrue);
      });
    });

    group('orEmpty', () {
      test('should return empty string when input is null', () {
        String? input;
        expect(input.orEmpty(), equals(''));
      });

      test('should return same string when input is not null', () {
        const String input = 'hello';
        expect(input.orEmpty(), equals('hello'));
      });

      test('should return empty string when input is empty', () {
        const String input = '';
        expect(input.orEmpty(), equals(''));
      });

      test('should return string with spaces when input has spaces', () {
        const String input = '   ';
        expect(input.orEmpty(), equals('   '));
      });
    });
  });

  group('StringsExtension', () {
    group('longestString', () {
      test('should return empty string for empty list', () {
        final input = <String>[];
        expect(input.longestString, equals(''));
      });

      test('should return single string for list with one element', () {
        final input = ['hello'];
        expect(input.longestString, equals('hello'));
      });

      test('should return longest string from multiple strings', () {
        final input = ['a', 'hello', 'hi', 'world'];
        expect(input.longestString, equals('hello'));
      });

      test(
        'should return first longest string when multiple strings have same length',
        () {
          final input = ['hello', 'world', 'tests'];
          expect(input.longestString, equals('hello'));
        },
      );

      test('should handle empty strings in list', () {
        final input = ['', 'hello', '', 'world'];
        expect(input.longestString, equals('hello'));
      });

      test('should return empty string when all strings are empty', () {
        final input = ['', '', ''];
        expect(input.longestString, equals(''));
      });

      test('should handle strings with special characters', () {
        final input = ['hello!', '@world#', 'test'];
        expect(input.longestString, equals('@world#'));
      });

      test('should handle strings with numbers', () {
        final input = ['123', '12345', '1234'];
        expect(input.longestString, equals('12345'));
      });

      test('should handle strings with unicode characters', () {
        final input = ['hello', 'héllo', 'hëllö'];
        expect(input.longestString, equals('hello'));
      });
    });
  });
}
