part of 'personal_summary_widget.dart';

class _BackdropNameWidget extends StatelessWidget {
  const _BackdropNameWidget({required this.name, required this.isVisible});

  final String name;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.surface.onInverseSurface.color;

    return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            name.toUpperCase(),
            maxLines: 1,
            style: context.typography.emphasizedDisplaySmall.textStyle.copyWith(
              fontSize: 260,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: color.withAlpha(24),
            ),
          ),
        )
        .animate(target: isVisible ? 1 : 0)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.1, duration: 600.ms, curve: Curves.easeOut);
  }
}
