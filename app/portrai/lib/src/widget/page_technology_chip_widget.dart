import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Pill with a gradient dot that lifts and highlights while hovered.
class PageTechnologyChipWidget extends StatefulWidget {
  const PageTechnologyChipWidget({super.key, required this.label});

  final String label;

  @override
  State<PageTechnologyChipWidget> createState() =>
      _PageTechnologyChipWidgetState();
}

class _PageTechnologyChipWidgetState extends State<PageTechnologyChipWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovering ? -3 : 0, 0),
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
          vertical: context.space(factor: 1.25),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: palette.surface.surface.color,
          border: Border.all(
            color: _hovering ? accent : palette.neutral.grey3.color,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(_hovering ? 60 : 16),
              blurRadius: _hovering ? 18 : 8,
              offset: Offset(0, _hovering ? 8 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 1.25),
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent, palette.brand.tertiary.color],
                ),
              ),
            ),
            Flexible(
              child: DSTextWidget(
                widget.label,
                style: context.typography.emphasizedBodyMedium,
                color: palette.neutral.grey10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
