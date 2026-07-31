import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storybook/main.directories.g.dart';
import 'package:storybook/src/widget/home_screen.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StorybookApp());
}

@App()
class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      home: const HomeScreen(),
      appBuilder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            actions: [
              Chip(
                label: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Text('Version: ${snapshot.data!.version}');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                labelStyle: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                  letterSpacing: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 16),
            ],
            title: SizedBox(width: 40, height: 40, child: DSImage.logo()),
          ),
          body: child,
        );
      },
      addons: [
        ViewportAddon([
          Viewports.none,
          ...IosViewports.all,
          ...AndroidViewports.all,
        ]),
        TextScaleAddon(initialScale: 1),
        ThemeAddon<_CustomTheme>(
          themes: [
            WidgetbookTheme(
              name: 'Beltane Light Theme ',
              data: _CustomTheme(Brightness.light, DesignSystem.beltane),
            ),
            WidgetbookTheme(
              name: 'Beltane Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.beltane),
            ),
            WidgetbookTheme(
              name: 'Carnival Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.carnival),
            ),
            WidgetbookTheme(
              name: 'Carnival Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.carnival),
            ),
            WidgetbookTheme(
              name: 'Chuseok Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.chuseok),
            ),
            WidgetbookTheme(
              name: 'Chuseok Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.chuseok),
            ),
            WidgetbookTheme(
              name: 'Diwali Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.diwali),
            ),
            WidgetbookTheme(
              name: 'Diwali Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.diwali),
            ),
            WidgetbookTheme(
              name: 'Halloween Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.halloween),
            ),
            WidgetbookTheme(
              name: 'Halloween Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.halloween),
            ),
            WidgetbookTheme(
              name: 'Hogeras Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.hogeras),
            ),
            WidgetbookTheme(
              name: 'Hogeras Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.hogeras),
            ),
            WidgetbookTheme(
              name: 'Hogmanay Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.hogmanay),
            ),
            WidgetbookTheme(
              name: 'Hogmanay Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.hogmanay),
            ),
            WidgetbookTheme(
              name: 'Holi Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.holi),
            ),
            WidgetbookTheme(
              name: 'Holi Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.holi),
            ),
            WidgetbookTheme(
              name: 'Obon Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.obon),
            ),
            WidgetbookTheme(
              name: 'Obon Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.obon),
            ),
            WidgetbookTheme(
              name: 'Pachamama Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.pachamama),
            ),
            WidgetbookTheme(
              name: 'Pachamama Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.pachamama),
            ),
            WidgetbookTheme(
              name: 'Sakura Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.sakura),
            ),
            WidgetbookTheme(
              name: 'Sakura Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.sakura),
            ),
            WidgetbookTheme(
              name: 'Xmas Light Theme',
              data: _CustomTheme(Brightness.light, DesignSystem.xmas),
            ),
            WidgetbookTheme(
              name: 'Xmas Dark Theme',
              data: _CustomTheme(Brightness.dark, DesignSystem.xmas),
            ),
          ],
          themeBuilder: (context, theme, child) {
            return DSThemeBuilderWidget(
              designSystem: theme.designSystem,
              brightness: theme.brightness,
              child: child,
            );
          },
        ),
      ],
    );
  }
}

class _CustomTheme {
  _CustomTheme(this.brightness, this.designSystem);

  final Brightness brightness;
  final DesignSystem designSystem;
}
