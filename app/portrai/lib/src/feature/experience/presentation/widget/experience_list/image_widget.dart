part of 'experience_list_widget.dart';

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({
    required this.experience,
    required this.size,
    this.shape = BoxShape.rectangle,
  });

  final ExperienceEntity experience;
  final double size;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'experience-image-${experience.id}',
      child: DSNetworkImageWidget(
        url: experience.companyLogo,
        fit: BoxFit.contain,
        shape: shape,
        width: size,
        height: size,
        borderRadius: BorderRadius.all(
          Radius.circular(context.dimen.radiusLevel3.value),
        ),
      ),
    );
  }
}
