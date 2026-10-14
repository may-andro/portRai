import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_state.dart';

extension ContextExtension on BuildContext {
  ExpertisesBloc get bloc => read<ExpertisesBloc>();

  ExpertisesState get state => bloc.state;
}
