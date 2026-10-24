import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/notification/data/_data.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

void main() {
  group('PushMessageMapper', () {
    for (final (kind, expected) in [
      ('job_openings', PushMessageKind.jobOpenings),
      ('portfolio_update', PushMessageKind.portfolioUpdate),
      ('something_else', PushMessageKind.unknown),
    ]) {
      test('should read $expected when the kind is $kind', () {
        final message = const PushMessageMapper().map(
          FbPushMessage(title: 'Title', body: 'Body', data: {'kind': kind}),
        );

        expect(
          message,
          PushMessageEntity(kind: expected, title: 'Title', body: 'Body'),
        );
      });
    }

    test('should read an unknown kind when the data has none', () {
      expect(
        const PushMessageMapper().map(const FbPushMessage()).kind,
        PushMessageKind.unknown,
      );
    });
  });
}
