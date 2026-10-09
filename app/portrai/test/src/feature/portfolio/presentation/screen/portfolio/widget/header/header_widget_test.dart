import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/header/header_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/setting_button_widget.dart';

import '../../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<void> pumpHeader(WidgetTester tester, double width) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final bloc = MockPortfolioBloc()..stubState(const LoadingState());
    addTearDown(bloc.close);
    final sections = createPortfolioEntity().scrollableSections;

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<PortfolioBloc>.value(
          value: bloc,
          child: DefaultTabController(
            length: sections.length,
            child: Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    HeaderWidget(
                      sections: sections,
                      tabController: DefaultTabController.of(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HeaderWidget', () {
    for (final width in [400.0, 800.0]) {
      testWidgets(
        'should keep settings visible when the viewport is $width pixels wide',
        (tester) async {
          await pumpHeader(tester, width);

          expect(find.byType(SettingButtonWidget), findsOneWidget);
          expect(find.byIcon(Icons.settings).hitTestable(), findsOneWidget);
          final buttonRect = tester.getRect(find.byType(SettingButtonWidget));
          expect(buttonRect.left, greaterThanOrEqualTo(0));
          expect(buttonRect.right, lessThanOrEqualTo(width));
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final width in [1024.0, 1440.0]) {
      testWidgets(
        'should omit settings when the desktop header is $width pixels wide',
        (tester) async {
          await pumpHeader(tester, width);

          expect(find.byType(SettingButtonWidget), findsNothing);
          expect(find.byType(TabBar), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'should scroll navigation tabs when the desktop header has limited space',
      (tester) async {
        await pumpHeader(tester, 1024);

        final context = tester.element(find.byType(HeaderWidget));
        expect(context.isDesktop, isTrue);
        final firstTabPosition = tester.getTopLeft(
          find.byType(DSTabItemWidget).first,
        );

        await tester.drag(find.byType(TabBar), const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.byType(DSTabItemWidget).first).dx,
          lessThan(firstTabPosition.dx),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
