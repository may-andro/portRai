import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_state.dart';

extension ContextExtension on BuildContext {
  ExperiencesBloc get bloc => read<ExperiencesBloc>();

  ExperiencesState get state => bloc.state;
}
