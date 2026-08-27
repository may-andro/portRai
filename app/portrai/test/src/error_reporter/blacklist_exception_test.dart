import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/error_reporter/blacklist_exception.dart';

void main() {
  group('BlacklistException', () {
    test('should implement AppException when instantiated', () {
      final exception = BlacklistException();

      expect(exception, isA<AppException>());
    });

    test(
      'should create distinct instances when instantiated multiple times',
      () {
        final exception1 = BlacklistException();
        final exception2 = BlacklistException();

        expect(exception1, isNot(same(exception2)));
      },
    );
  });
}
