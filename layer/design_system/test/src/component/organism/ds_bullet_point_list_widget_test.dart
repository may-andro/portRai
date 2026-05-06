import 'package:design_system/design_system.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSBulletPointListWidget',
    (theme) => [
      const TestCase(
        'few items',
        DSBulletPointListWidget(
          bulletPoints: [
            'Designed and developed the architecture',
            'Led a team of 4 engineers',
            'Reduced build time by 40%',
          ],
        ),
      ),
      const TestCase(
        'many items',
        DSBulletPointListWidget(
          bulletPoints: [
            'Delivered cross-platform mobile app',
            'Integrated Firebase Auth and Firestore',
            'Wrote unit and widget tests',
            'Performed code reviews',
            'Maintained CI/CD pipeline',
            'Collaborated with design team',
          ],
        ),
      ),
    ],
  );
}
