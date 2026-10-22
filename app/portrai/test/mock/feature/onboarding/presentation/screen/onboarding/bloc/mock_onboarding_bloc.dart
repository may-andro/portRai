import 'package:bloc_test/bloc_test.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/_bloc.dart';

class MockOnboardingBloc extends MockBloc<OnboardingEvent, OnboardingState>
    implements OnboardingBloc {}
