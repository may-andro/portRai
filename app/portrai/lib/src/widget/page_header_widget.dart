import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Logo header shown at the top of desktop screens.
class PageHeaderWidget extends StatelessWidget {
  const PageHeaderWidget({this.actions = const [], super.key});

  /// Shown at the end of the header, after the logo.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
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
