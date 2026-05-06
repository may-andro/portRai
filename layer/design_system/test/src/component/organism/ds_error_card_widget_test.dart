import 'package:design_system/design_system.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSErrorCardWidget',
    (theme) => [
      const TestCase('default', DSErrorCardWidget()),
      const TestCase(
        'with custom message',
        DSErrorCardWidget(
          message: 'Failed to load data. Check your connection.',
        ),
      ),
      TestCase(
        'with retry button',
        DSErrorCardWidget(
          message: 'Could not reach the server.',
          onRetryClicked: () {},
        ),
      ),
    ],
  );
}
