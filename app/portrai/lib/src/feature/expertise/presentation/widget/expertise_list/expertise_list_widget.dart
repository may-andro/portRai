import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

part 'image_widget.dart';

part 'skills_widget.dart';

part 'title_widget.dart';

part 'mobile_content_widget.dart';

part 'desktop_content_widget.dart';

class ExpertiseListWidget extends StatelessWidget {
  const ExpertiseListWidget({
    super.key,
    required this.allExpertise,
    required this.isVisible,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(
          allExpertise: allExpertise,
          isVisible: isVisible,
        );
      },
      tabletBuilder: (_) {
        return _MobileContentWidget(
          allExpertise: allExpertise,
          isVisible: isVisible,
        );
      },
      desktopBuilder: (_) {
        return _DesktopContentWidget(
          allExpertise: allExpertise,
          isVisible: isVisible,
        );
      },
    );
  }
}

extension PortfolioBuildContextExtension on BuildContext {
  double get _mobileImageSize => space(factor: 8);

  double get _tabletImageSize => space(factor: 7);

  double get _desktopImageSize => space(factor: 5);

  double get expertiesImageSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return _mobileImageSize;
      case DSDeviceResolution.tablet:
        return _tabletImageSize;
      case DSDeviceResolution.desktop:
        return _desktopImageSize;
    }
  }
}
