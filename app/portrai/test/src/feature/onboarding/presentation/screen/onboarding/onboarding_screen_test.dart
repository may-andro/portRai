import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/_onboarding.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../mock/feature/onboarding/presentation/screen/onboarding/bloc/mock_onboarding_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets('should add the started event when the screen is created', (
    tester,
  ) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final bloc = MockOnboardingBloc();
    whenListen(
      bloc,
      const Stream<OnboardingState>.empty(),
      initialState: const OnboardingState(),
    );
    await appServiceLocator.reset();
    addTearDown(appServiceLocator.reset);
    appServiceLocator.registerFactory<OnboardingBloc>(() => bloc);

    await tester.pumpWidget(const TestWidgetWrapper(child: OnboardingScreen()));
    // The background animates forever, so pumpAndSettle would time out.
    await tester.pump(const Duration(seconds: 2));

    verify(() => bloc.add(const OnboardingStartedEvent())).called(1);
  });
}
