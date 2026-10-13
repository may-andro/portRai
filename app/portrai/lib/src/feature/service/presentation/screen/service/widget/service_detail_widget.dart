import 'dart:math';

import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

part 'section_widget.dart';

part 'header_widget.dart';

part 'faq_widget.dart';

part 'motion_widget.dart';

/// Details of a [ServiceEntity], laid out as a column of styled sections.
class ServiceDetailWidget extends StatelessWidget {
  const ServiceDetailWidget({super.key, required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 3),
      children: [
        _RevealWidget(
          child: _HoverLiftWidget(child: _HeaderWidget(service: service)),
        ),
        _RevealWidget(
          index: 1,
          child: Container(
            padding: EdgeInsets.only(left: context.space(factor: 2)),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: context.colorPalette.accent.color,
                  width: 3,
                ),
              ),
            ),
            child: DSTextWidget(
              service.detail,
              style: context.typography.titleMedium,
              color: context.colorPalette.neutral.grey10,
              isItalic: true,
            ),
          ),
        ),
        if (service.deliverables.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailDeliverables,
            icon: Icons.inventory_2_outlined,
            child: _CheckListWidget(
              items: service.deliverables,
              icon: Icons.check_circle_rounded,
            ),
          ),
        if (service.process.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailProcess,
            style: _SectionStyle.plain,
            icon: Icons.route_outlined,
            child: _StepsWidget(steps: service.process),
          ),
        if (service.technologies.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailTechnologies,
            style: _SectionStyle.dark,
            icon: Icons.code_rounded,
            child: _TagsWidget(tags: service.technologies),
          ),
        if (service.idealFor.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailIdealFor,
            style: _SectionStyle.accentBar,
            icon: Icons.track_changes_rounded,
            child: _CheckListWidget(
              items: service.idealFor,
              icon: Icons.arrow_circle_right_rounded,
            ),
          ),
        if (service.engagementTypes.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailEngagement,
            style: _SectionStyle.outlined,
            icon: Icons.handshake_outlined,
            child: _TagsWidget(tags: service.engagementTypes),
          ),
        if (service.faq.isNotEmpty)
          _SectionWidget(
            title: context.localizations.serviceDetailFaq,
            style: _SectionStyle.neutral,
            icon: Icons.help_outline_rounded,
            child: _FaqWidget(faq: service.faq),
          ),
      ],
    );
  }
}
