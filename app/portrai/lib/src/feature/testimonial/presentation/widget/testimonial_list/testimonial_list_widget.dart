import 'dart:math';

import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

part 'card_item_widget.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

// Room for the hover lift and the card shadow so the section doesn't clip them.
const _hoverLift = 8.0;
const _shadowRoom = 36.0;

class TestimonialListWidget extends StatelessWidget {
  const TestimonialListWidget({
    required this.testimonials,
    required this.isVisible,
    super.key,
  });

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _hoverLift, bottom: _shadowRoom),
      child: DSResponsiveContainerWidget(
        mobileBuilder: (_) {
          return _MobileContentWidget(
            testimonials: testimonials,
            isVisible: isVisible,
          );
        },
        tabletBuilder: (_) {
          return _TabletContentWidget(
            testimonials: testimonials,
            isVisible: isVisible,
          );
        },
        desktopBuilder: (_) {
          return _DesktopContentWidget(
            testimonials: testimonials,
            isVisible: isVisible,
          );
        },
      ),
    );
  }
}
