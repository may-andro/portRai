import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_state.dart';

extension ContextExtension on BuildContext {
  ExpertiseBloc get bloc => read<ExpertiseBloc>();

  ExpertiseState get state => bloc.state;
}
