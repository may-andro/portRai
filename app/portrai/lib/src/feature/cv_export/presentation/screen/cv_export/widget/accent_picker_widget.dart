part of 'content_widget.dart';

class _AccentPickerWidget extends StatelessWidget {
  const _AccentPickerWidget({required this.selectedAccent});

  final CvAccent selectedAccent;

  @override
  Widget build(BuildContext context) {
    final swatchSize = context.space(factor: 4);

    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final accent in CvAccent.values)
          Tooltip(
            message: accent.label(context),
            child: InkResponse(
              onTap: () => context.bloc.add(SelectCvAccentClickEvent(accent)),
              child: Container(
                width: swatchSize,
                height: swatchSize,
                decoration: BoxDecoration(
                  color: Color(accent.argb),
                  shape: BoxShape.circle,
                  border: accent == selectedAccent
                      ? Border.all(
                          color: context.colorPalette.surface.onSurface.color,
                          width: 2,
                        )
                      : null,
                ),
                child: accent == selectedAccent
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
