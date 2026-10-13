import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/route/route.dart';

part 'section_widget.dart';

part 'header_widget.dart';

part 'faq_widget.dart';

/// Details of a [ServiceEntity], shown as a dialog on web and as a bottom sheet
/// on other platforms.
class ServiceDetailWidget extends StatelessWidget {
  const ServiceDetailWidget({super.key, required this.service});

  final ServiceEntity service;

  static Future<void> show(BuildContext context, ServiceEntity service) {
    if (kIsWeb) {
      return showDialog<void>(
        context: context,
        builder: (_) {
          return DSDialogWidget(
            maxWidth: 640,
            child: ServiceDetailWidget(service: service),
          );
        },
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colorPalette.background.color,
      constraints: BoxConstraints(maxHeight: context.height * 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dimen.radiusLevel3.value),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.space(factor: 2),
            context.space(factor: 2),
            context.space(factor: 2),
            0,
          ),
          child: ServiceDetailWidget(service: service),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: context.space(factor: 3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: [
          _HeaderWidget(service: service),
          DSTextWidget(
            service.detail,
            style: context.typography.bodyLarge,
            color: context.colorPalette.neutral.grey9,
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
              icon: Icons.route_outlined,
              child: _StepsWidget(steps: service.process),
            ),
          if (service.technologies.isNotEmpty)
            _SectionWidget(
              title: context.localizations.serviceDetailTechnologies,
              icon: Icons.code_rounded,
              child: _TagsWidget(tags: service.technologies),
            ),
          if (service.idealFor.isNotEmpty)
            _SectionWidget(
              title: context.localizations.serviceDetailIdealFor,
              icon: Icons.track_changes_rounded,
              child: _CheckListWidget(
                items: service.idealFor,
                icon: Icons.arrow_circle_right_rounded,
              ),
            ),
          if (service.engagementTypes.isNotEmpty)
            _SectionWidget(
              title: context.localizations.serviceDetailEngagement,
              icon: Icons.handshake_outlined,
              child: _TagsWidget(tags: service.engagementTypes),
            ),
          if (service.faq.isNotEmpty)
            _SectionWidget(
              title: context.localizations.serviceDetailFaq,
              icon: Icons.help_outline_rounded,
              child: _FaqWidget(faq: service.faq),
            ),
          _FooterArtWidget(imageUrl: service.image),
        ],
      ),
    );
  }
}
