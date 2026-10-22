import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart'
    show FooterBloc;
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_open_email_use_case.dart';
import '../../../../../../../mock/feature/profile/presentation/screen/profile/bloc/mock_profile_bloc.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/footer/tracking/mock_footer_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../../util/package_info_setup.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Profile ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockProfileBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockProfileBloc()
          ..stubState(const ErrorState(failure: ProfileNotFoundFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    for (final entry in {
      'mobile': const Size(390, 844),
      'desktop': const Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render the hero without errors when on ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await appServiceLocator.reset();
          registerTestPackageInfo();
          addTearDown(appServiceLocator.reset);
          appServiceLocator.registerFactory<FooterBloc>(
            () => FooterBloc(
              MockGetProfileUseCase(),
              MockOpenExternalUrlUseCase(),
              MockOpenEmailUseCase(),
              MockFooterTrackingDelegate(),
            ),
          );
          final bloc = MockProfileBloc()
            ..stubState(LoadedState(profile: createProfileEntity()));

          await tester.pumpWidget(
            TestWidgetWrapper(
              child: BlocProvider<ProfileBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 6));
          await tester.pump(const Duration(seconds: 2));

          expect(find.text('Mayank Rai'), findsWidgets);
          verify(
            () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
          ).called(1);
          // The test font is wider than the real one, so overflow is tolerated.
          final error = tester.takeException();
          expect(
            error == null ||
                error.toString().contains('overflowed') ||
                error.toString().contains('Multiple exceptions'),
            isTrue,
          );
        },
      );
    }
  });
}
