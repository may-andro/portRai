part of 'content_widget.dart';

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Row(
        children: [
          Image.asset(
            DSImage.logoPath,
            package: 'design_system',
            height: context.space(factor: 5),
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
