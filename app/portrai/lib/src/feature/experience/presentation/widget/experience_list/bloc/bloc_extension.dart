import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/experience_list_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/experience_list_state.dart';

extension ContextExtension on BuildContext {
  ExperienceListBloc get bloc => read<ExperienceListBloc>();

  ExperienceListState get state => bloc.state;
}
