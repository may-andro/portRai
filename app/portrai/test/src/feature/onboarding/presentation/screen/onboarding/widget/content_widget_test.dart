import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/_bloc.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/widget/content_widget.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../../mock/feature/onboarding/presentation/screen/onboarding/tracking/mock_onboarding_tracking_delegate.dart';
import '../../../../../../../mock/feature/user/domain/use_case/mock_save_guest_user_use_case.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('ContentWidget', () {
    late MockSaveGuestUserUseCase saveGuestUserUseCase;

    setUp(() {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
      saveGuestUserUseCase = MockSaveGuestUserUseCase();
      for (final role in UserRole.values) {
        saveGuestUserUseCase.stubCall(
          GuestUserEntity(role: role),
          const Right(null),
        );
      }
    });

    Future<void> pumpContent(WidgetTester tester, Size size) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final bloc = OnboardingBloc(
        saveGuestUserUseCase,
        MockOnboardingTrackingDelegate(),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(value: bloc, child: const ContentWidget()),
        ),
      );
      // The background animates forever, so pumpAndSettle would time out.
      await tester.pump(const Duration(seconds: 2));
    }

    for (final size in const [
      Size(360, 740),
      Size(800, 1000),
      Size(1440, 900),
    ]) {
      testWidgets(
        'should show every role without overflow when the viewport is ${size.width} wide',
        (tester) async {
          await pumpContent(tester, size);

          expect(tester.takeException(), isNull);
          expect(find.text("I'm a developer"), findsOneWidget);
          expect(find.text("I'm a recruiter"), findsOneWidget);
          expect(find.text('Just exploring'), findsOneWidget);
        },
      );
    }

    testWidgets('should save the matching user when a role card is tapped', (
      tester,
    ) async {
      await pumpContent(tester, const Size(800, 1000));

      await tester.tap(find.text("I'm a recruiter"));
      await tester.pump();

      verify(
        () => saveGuestUserUseCase(
          const GuestUserEntity(role: UserRole.recruiter),
        ),
      ).called(1);
    });
  });
}
