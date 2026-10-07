part of 'expertise_list_widget.dart';

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return DSNetworkImageWidget(
      url: imageUrl,
      width: context.expertiseImageSize,
      height: context.expertiseImageSize,
      shape: BoxShape.circle,
      fit: BoxFit.cover,
      //color: context.colorPalette.surface.inverseSurface,
    );
  }
}
