import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/setting_button_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart' as summary;
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/professional_summary/bloc/mock_professional_summary_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(() async {
    resetTrackingImpressions();
    await appServiceLocator.reset();
  });

  tearDown(() async {
    await appServiceLocator.reset();
  });

  Future<void> pumpIntro(WidgetTester tester, double width) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final bloc = MockPortfolioBloc()..stubState(const LoadingState());
    addTearDown(bloc.close);
    final summaryBloc = MockProfessionalSummaryBloc()..stubLoadingState();
    appServiceLocator.registerFactory<summary.ProfessionalSummaryBloc>(
      () => summaryBloc,
    );

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<PortfolioBloc>.value(
          value: bloc,
          child: SingleChildScrollView(
            child: IntroSectionWidget(portfolio: createPortfolioEntity()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('IntroSectionWidget', () {
    for (final width in [1024.0, 1440.0]) {
      testWidgets(
        'should show settings in the top-right corner when the desktop viewport is $width pixels wide',
        (tester) async {
          await pumpIntro(tester, width);

          final context = tester.element(find.byType(IntroSectionWidget));
          expect(context.isDesktop, isTrue);
          expect(find.byIcon(Icons.settings).hitTestable(), findsOneWidget);
          final sectionRect = tester.getRect(find.byType(IntroSectionWidget));
          final buttonRect = tester.getRect(find.byType(SettingButtonWidget));
          expect(buttonRect.top, sectionRect.top + context.space(factor: 2));
          expect(
            buttonRect.right,
            sectionRect.right - context.space(factor: 2),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final width in [400.0, 800.0]) {
      testWidgets(
        'should omit settings from the intro when the viewport is $width pixels wide',
        (tester) async {
          await pumpIntro(tester, width);

          expect(find.byType(SettingButtonWidget), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
