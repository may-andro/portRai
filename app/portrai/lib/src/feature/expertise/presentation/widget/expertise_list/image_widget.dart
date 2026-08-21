part of 'expertise_list_widget.dart';

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return DSNetworkImageWidget(
      url: imageUrl,
      width: context.expertiesImageSize,
      height: context.expertiesImageSize,
      shape: BoxShape.circle,
      fit: BoxFit.cover,
      //color: context.colorPalette.surface.inverseSurface,
    );
  }
}
