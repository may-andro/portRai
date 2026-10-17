import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_bloc.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/onboarding_state.dart';

extension ContextExtension on BuildContext {
  OnboardingBloc get bloc => read<OnboardingBloc>();

  OnboardingState get state => bloc.state;
}
