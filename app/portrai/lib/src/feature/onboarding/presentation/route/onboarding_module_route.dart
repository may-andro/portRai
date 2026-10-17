import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:portrai/src/route/route.dart';

class OnboardingModuleRoute extends ModuleRoute {
  OnboardingModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final OnboardingModuleRoute onboarding = OnboardingModuleRoute._(
    name: 'onboarding',
    path: '/onboarding',
    builder: (_, _, _) => const OnboardingScreen(),
  );
}
