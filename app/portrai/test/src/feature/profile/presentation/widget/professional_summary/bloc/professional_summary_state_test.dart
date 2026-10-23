import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_state.dart';

import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  group('ProfessionalSummary LoadedState', () {
    test(
      'should return the profile social links when appSocialLinks is read',
      () {
        final profile = createProfileEntity();
        final state = LoadedState(profile: profile);

        expect(state.appSocialLinks, profile.socialLinks);
      },
    );
  });
}
