import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

extension PortfolioIconButtonSizeExtension on BuildContext {
  DSIconButtonSize get portfolioIconButtonSize {
    return isMobile ? DSIconButtonSize.large : DSIconButtonSize.small;
  }
}
