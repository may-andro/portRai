import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Logo header shown at the top of desktop screens.
class PageHeaderWidget extends StatelessWidget {
  const PageHeaderWidget({this.actions = const [], super.key});

  /// Shown at the end of the header, after the logo.
  final List<Widget> actions;

  /// Distance from the screen edges to the logo and the actions: the screen
  /// padding, so the header lines up with the content and the footer.
  static double horizontalPadding(BuildContext context) {
    return context.screenHorizontalPadding.left;
  }

  /// Height of the header, for content that sits below it when overlaid.
  static double height(BuildContext context) => context.space(factor: 7);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height(context),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding(context)),
      child: Row(
        children: [
          // Takes the free width so the actions sit at the end of the row.
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                DSImage.logoPath,
                package: 'design_system',
                fit: BoxFit.cover,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
