import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_state.dart';

extension ContextExtension on BuildContext {
  ExperienceBloc get bloc => read<ExperienceBloc>();

  ExperienceState get state => bloc.state;
}
