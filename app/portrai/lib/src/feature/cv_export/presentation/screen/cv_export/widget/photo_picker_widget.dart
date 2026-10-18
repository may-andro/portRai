part of 'content_widget.dart';

/// The profile images to pick the CV photo from.
class _PhotoPickerWidget extends StatelessWidget {
  const _PhotoPickerWidget({
    required this.photoUrls,
    required this.selectedPhotoUrl,
  });

  final List<String> photoUrls;
  final String selectedPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final photoSize = context.space(factor: 9);

    return _OptionCardWidget(
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Wrap(
          spacing: context.space(factor: 1.5),
          runSpacing: context.space(factor: 1.5),
          children: [
            for (final (index, photoUrl) in photoUrls.indexed)
              InkResponse(
                onTap: () {
                  context.bloc.add(
                    SelectCvPhotoClickEvent(photoUrl: photoUrl, index: index),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: photoSize * 0.8,
                  height: photoSize,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(photoSize * 0.2),
                    border: Border.all(
                      color: photoUrl == selectedPhotoUrl
                          ? context.colorPalette.neutral.grey1.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(photoSize * 0.16),
                    child: ColoredBox(
                      color: context.colorPalette.neutral.grey3.color,
                      child: Image.network(photoUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
