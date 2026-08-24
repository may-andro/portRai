import 'package:design_system/design_system.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSTabItemWidget',
    (theme) => [
      TestCase('default', DSTabItemWidget(title: 'Projects', onTap: () {})),
      TestCase(
        'selected',
        DSTabItemWidget(title: 'Projects', onTap: () {}, isSelected: true),
      ),
      TestCase(
        'selected with indicator',
        DSTabItemWidget(
          title: 'Experience',
          onTap: () {},
          isSelected: true,
          isIndicatorEnabled: true,
        ),
      ),
      TestCase(
        'unselected with indicator',
        DSTabItemWidget(title: 'Services', onTap: () {}),
      ),
    ],
  );
}
