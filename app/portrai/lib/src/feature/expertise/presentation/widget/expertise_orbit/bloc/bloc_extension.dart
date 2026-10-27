import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/expertise_orbit_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/expertise_orbit_state.dart';

extension ContextExtension on BuildContext {
  ExpertiseOrbitBloc get bloc => read<ExpertiseOrbitBloc>();

  ExpertiseOrbitState get state => bloc.state;
}
