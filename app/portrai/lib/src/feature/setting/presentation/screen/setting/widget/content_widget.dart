import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/developer_menu_screen.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/language_card_widget.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/section_title_widget.dart';

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.state});

  final SettingLoadedState state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.getFormCardWidth(constraints),
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                  vertical: context.space(factor: context.isDesktop ? 2 : 0),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.isLanguageSelectorEnabled) ...[
                        SectionTitleWidget(
                          title: context.localizations.language,
                        ),
                        const LanguageCardWidget(),
                      ],
                      const DSVerticalSpacerWidget(3),
                      DSButtonWidget(
                        label: 'Developer Mode',
                        onPressed: () => DeveloperMenuScreen.navigate(context),
                        variant: DSButtonVariant.text,
                        size: DSButtonSize.small,
                      ),
                      const Spacer(),
                      const DSVerticalSpacerWidget(3),
                      SafeArea(
                        child: Align(
                          child: DSTextWidget(
                            context.localizations.version('v1.0.0'),
                            style: context.typography.emphasizedLabelSmall,
                            color: context.colorPalette.onBackground,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const DSVerticalSpacerWidget(2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension on BuildContext {
  double getFormCardWidth(BoxConstraints constraints) {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
        return constraints.maxWidth;
      case DSDeviceWidthResolution.s:
        return constraints.maxWidth;
      case DSDeviceWidthResolution.m:
        return constraints.maxWidth * 0.8;
      case DSDeviceWidthResolution.l:
        return constraints.maxWidth * 0.7;
      case DSDeviceWidthResolution.xl:
        return constraints.maxWidth * 0.5;
    }
  }
}
