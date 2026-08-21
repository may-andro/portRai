import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/project_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/project_state.dart';

extension ContextExtension on BuildContext {
  ProjectBloc get bloc => read<ProjectBloc>();

  ProjectState get state => bloc.state;
}
