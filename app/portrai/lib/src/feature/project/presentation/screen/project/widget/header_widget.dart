part of 'content_widget.dart';

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({required this.sections, required this.tabController});

  final List<ScrollableProjectSectionDTO> sections;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Image.asset(
              DSImage.logoPath,
              package: 'design_system',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: DSTabItemWidget.getHeight(context),
            child: _TabBarWidget(
              sections: sections,
              tabController: tabController,
            ),
          ),
        ],
      ),
    );
  }
}
