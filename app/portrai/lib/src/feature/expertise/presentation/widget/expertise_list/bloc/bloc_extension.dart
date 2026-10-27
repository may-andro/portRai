import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/expertise_list_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/expertise_list_state.dart';

extension ContextExtension on BuildContext {
  ExpertiseListBloc get bloc => read<ExpertiseListBloc>();

  ExpertiseListState get state => bloc.state;
}
