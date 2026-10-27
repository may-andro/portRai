import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/setting_button_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../../mock/feature/ai_image_gen/presentation/bloc/mock_ai_image_bloc.dart';
import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/professional_summary/bloc/mock_professional_summary_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
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

  Future<MockPortfolioBloc> pumpSection(
    WidgetTester tester,
    double width,
    Widget section,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final bloc = MockPortfolioBloc()..stubState(const LoadingState());
    addTearDown(bloc.close);
    MockProfessionalSummaryBloc()
      ..stubLoadingState()
      ..registerFactory();
    MockAiImageBloc()
      ..stubLoadingState()
      ..registerFactory();

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<PortfolioBloc>.value(
          value: bloc,
          child: SingleChildScrollView(child: section),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    return bloc;
  }

  Future<MockPortfolioBloc> pumpIntro(WidgetTester tester, double width) =>
      pumpSection(
        tester,
        width,
        IntroSectionWidget(portfolio: createPortfolioEntity()),
      );

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

  testWidgets('should track the settings tap when settings is tapped on a '
      'desktop', (tester) async {
    final bloc = await pumpIntro(tester, 1440);

    await tester.tap(find.byType(SettingButtonWidget));
    await tester.pump();
    tester.takeException();

    verify(() => bloc.add(const SettingClickEvent('setting_button'))).called(1);
  });

  testWidgets('should track the See all tap when the services See all is '
      'tapped on a phone', (tester) async {
    setUpAnimatedPage(tester, size: const Size(400, 900));
    final bloc = await pumpSection(
      tester,
      400,
      ServicesSectionWidget(portfolio: createPortfolioEntity()),
    );

    await pumpAnimations(tester);
    await tester.ensureVisible(find.text('See All'));
    await pumpAnimations(tester);
    await tester.tap(find.text('See All'));
    await tester.pump();
    tester.takeException();

    verify(
      () => bloc.add(
        const SeeAllClickEvent(
          label: 'see_all_button',
          sectionName: 'services',
        ),
      ),
    ).called(1);
  });
}
