import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/ai_image_gen/presentation/bloc/mock_ai_image_bloc.dart';
import '../../../../../../mock/feature/profile/presentation/widget/professional_summary/bloc/mock_professional_summary_bloc.dart';
import '../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  final profile = createProfileEntity();

  tearDown(() => appServiceLocator.reset());

  Future<void> pumpWidget(
    WidgetTester tester, {
    required Size size,
    List<String> projectImages = const [],
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    MockProfessionalSummaryBloc()
      ..stubState(LoadedState(profile: profile))
      ..registerFactory();
    MockAiImageBloc()
      ..stubLoadingState()
      ..registerFactory();

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: SingleChildScrollView(
          child: ProfessionalSummaryWidget(
            profile: profile,
            isVisible: true,
            height: size.height,
            projectImages: projectImages,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  const sizes = {
    'mobile': Size(390, 844),
    'tablet': Size(820, 1180),
    'desktop': Size(1440, 900),
  };

  for (final entry in sizes.entries) {
    testWidgets(
      'should show current role and resume action when rendered on ${entry.key}',
      (tester) async {
        await pumpWidget(tester, size: entry.value);

        expect(
          find.textContaining(profile.currentCompany, findRichText: true),
          findsOneWidget,
        );
        expect(find.textContaining(profile.subtitle), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('should render without errors when project images are provided', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      size: sizes['mobile']!,
      projectImages: ['https://example.com/a.png', 'https://example.com/b.png'],
    );

    expect(tester.takeException(), isNull);
  });
}
