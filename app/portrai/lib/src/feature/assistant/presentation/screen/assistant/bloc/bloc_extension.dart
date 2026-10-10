import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_bloc.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_state.dart';

extension AssistantBlocContextExtension on BuildContext {
  AssistantBloc get bloc => read<AssistantBloc>();

  AssistantState get state => bloc.state;
}
