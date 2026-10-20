import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/auth/presentation/route/_route.dart';

void main() {
  group('AuthModuleRoute', () {
    test('should carry the requested location when building the sign-in '
        'location', () {
      final signInLocation = AuthModuleRoute.signInLocation(
        redirectUri: Uri.parse('/job-openings?sort=score'),
      );

      final signInUri = Uri.parse(signInLocation);
      expect(signInUri.path, '/sign-in');
      expect(
        signInUri.queryParameters[AuthModuleRoute.redirectQueryParameter],
        '/job-openings?sort=score',
      );
    });

    test('should follow the requested location when it is an in-app path', () {
      expect(
        AuthModuleRoute.redirectLocation('/job-openings?sort=score'),
        '/job-openings?sort=score',
      );
    });

    for (final (description, requestedLocation) in [
      ('it is missing', null),
      ('it is another site', 'https://example.com/job-openings'),
      ('it is a protocol-relative link', '//example.com/job-openings'),
      ('it is a relative path', 'job-openings'),
      ('it is the sign-in screen itself', '/sign-in'),
    ]) {
      test('should fall back to the start page when $description', () {
        expect(AuthModuleRoute.redirectLocation(requestedLocation), '/');
      });
    }
  });
}
