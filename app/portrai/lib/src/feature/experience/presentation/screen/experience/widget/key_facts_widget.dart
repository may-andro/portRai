import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/widget/page_band_widget.dart';

class KeyFactsWidget extends StatelessWidget {
  const KeyFactsWidget({super.key, required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final facts = [
      _Fact(
        icon: Icons.schedule_rounded,
        label: context.localizations.experienceFactDuration,
        value: _formattedDuration(),
        isCountable: false,
      ),
      _Fact(
        icon: Icons.memory_rounded,
        label: context.localizations.experienceSectionTechnologies,
        value: '${experience.technologies.length}',
      ),
      _Fact(
        icon: Icons.emoji_events_rounded,
        label: context.localizations.experienceSectionAchievements,
        value: '${experience.achievements.length}',
      ),
    ];
    return PageBandWidget(
      color: palette.surface.surfaceContainer.color,
      verticalFactor: 5,
      child: Row(
        children: [
          for (final (factIndex, fact) in facts.indexed) ...[
            if (factIndex != 0) _DividerWidget(),
            Expanded(child: _FactWidget(fact: fact)),
          ],
        ],
      ),
    );
  }

  String _formattedDuration() {
    final endDate = experience.endDate ?? DateTime.now();
    final startDate = experience.startDate;
    final totalMonths =
        ((endDate.year - startDate.year) * 12 +
                endDate.month -
                startDate.month +
                1)
            .clamp(1, 1200);
    final years = totalMonths ~/ 12;
    final remainingMonths = totalMonths % 12;
    if (years == 0) return '${remainingMonths}m';
    return remainingMonths == 0 ? '${years}y' : '${years}y ${remainingMonths}m';
  }
}

class _Fact {
  const _Fact({
    required this.label,
    required this.value,
    required this.icon,
    this.isCountable = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isCountable;
}

class _FactWidget extends StatelessWidget {
  const _FactWidget({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final valueStyle = context.typography.emphasizedHeadlineMedium;
    final valueColor = palette.brand.primary;
    final showIcon = context.deviceResolution != DSDeviceResolution.mobile;
    return Column(
      spacing: context.space(factor: 0.5),
      children: [
        if (showIcon)
          Container(
            padding: EdgeInsets.all(context.space(factor: 1.25)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.brand.primary.color.withAlpha(28),
            ),
            child: Icon(
              fact.icon,
              size: 22,
              color: palette.brand.primary.color,
            ),
          ),
        FittedBox(
          child: fact.isCountable
              ? CountUpWidget(
                  value: fact.value,
                  style: valueStyle,
                  color: valueColor,
                )
              : DSTextWidget(fact.value, style: valueStyle, color: valueColor),
        ),
        DSTextWidget(
          fact.label.toUpperCase(),
          style: context.typography.emphasizedLabelMedium,
          color: palette.neutral.grey7,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: context.space(factor: 6),
      color: context.colorPalette.neutral.grey3.color,
    );
  }
}
