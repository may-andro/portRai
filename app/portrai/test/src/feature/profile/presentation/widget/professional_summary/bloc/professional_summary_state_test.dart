import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_state.dart';

import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  group('ProfessionalSummary LoadedState', () {
    test(
      'should append the resume to the social links when appSocialLinks is read',
      () {
        final state = LoadedState(profile: createProfileEntity());

        expect(state.appSocialLinks.last.name, 'Resume');
        expect(state.appSocialLinks.last.url, 'https://example.com/resume.pdf');
        expect(state.appSocialLinks, hasLength(3));
      },
    );
  });
}
