part of 'content_widget.dart';

class _AccentPickerWidget extends StatelessWidget {
  const _AccentPickerWidget({required this.selectedAccent});

  final CvAccent selectedAccent;

  @override
  Widget build(BuildContext context) {
    final swatchSize = context.space(factor: 4.5);

    return Wrap(
      spacing: context.space(factor: 1.5),
      runSpacing: context.space(factor: 1.5),
      children: [
        for (final accent in CvAccent.values)
          Tooltip(
            message: accent.label(context),
            child: InkResponse(
              onTap: () => context.bloc.add(SelectCvAccentClickEvent(accent)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: swatchSize,
                height: swatchSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent == selectedAccent
                        ? Color(accent.argb)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(accent.argb),
                    shape: BoxShape.circle,
                  ),
                  child: accent == selectedAccent
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
