import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/project_list_bloc.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/project_list_state.dart';

extension ContextExtension on BuildContext {
  ProjectListBloc get bloc => read<ProjectListBloc>();

  ProjectListState get state => bloc.state;
}
