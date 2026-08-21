import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

part 'card_item_widget.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

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
    return DSResponsiveContainerWidget(
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
    );
  }
}
