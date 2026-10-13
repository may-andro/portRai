import 'dart:math';

import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

part 'card_item_widget.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'all_testimonials_widget.dart';

// Room for the hover lift and the card shadow so the section doesn't clip them.
const _hoverLift = 8.0;
const _shadowRoom = 36.0;

/// Number of testimonials shown on the portfolio screen before "see all".
const maxPreviewTestimonials = 2;

class TestimonialListWidget extends StatelessWidget {
  const TestimonialListWidget({
    required this.testimonials,
    required this.isVisible,
    super.key,
  });

  final List<TestimonialEntity> testimonials;
  final bool isVisible;

  /// Opens every testimonial in a scrollable sheet.
  static Future<void> showAll(
    BuildContext context,
    List<TestimonialEntity> testimonials,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colorPalette.background.color,
      constraints: BoxConstraints(maxHeight: context.height * 0.9),
      builder: (_) => _AllTestimonialsWidget(testimonials: testimonials),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testimonials = this.testimonials
        .take(maxPreviewTestimonials)
        .toList();

    return Padding(
      // The mobile carousel clips its own children, so it adds the room itself.
      padding: context.isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: _hoverLift, bottom: _shadowRoom),
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
