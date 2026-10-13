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
      showDragHandle: true,
      backgroundColor: context.colorPalette.background.color,
      constraints: BoxConstraints(maxHeight: context.height * 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dimen.radiusLevel3.value),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
          child: ServiceDetailWidget(service: service),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderWidget(service: service),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: context.space(factor: 2),
              bottom: context.space(factor: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 3),
              children: [
                DSTextWidget(
                  service.detail,
                  style: context.typography.bodyLarge,
                  color: context.colorPalette.neutral.grey9,
                ),
                if (service.deliverables.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailDeliverables,
                    child: DSBulletPointListWidget(
                      bulletPoints: service.deliverables,
                    ),
                  ),
                if (service.process.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailProcess,
                    child: _StepsWidget(steps: service.process),
                  ),
                if (service.technologies.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailTechnologies,
                    child: _TagsWidget(tags: service.technologies),
                  ),
                if (service.idealFor.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailIdealFor,
                    child: DSBulletPointListWidget(
                      bulletPoints: service.idealFor,
                    ),
                  ),
                if (service.engagementTypes.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailEngagement,
                    child: _TagsWidget(tags: service.engagementTypes),
                  ),
                if (service.faq.isNotEmpty)
                  _SectionWidget(
                    title: context.localizations.serviceDetailFaq,
                    child: _FaqWidget(faq: service.faq),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
