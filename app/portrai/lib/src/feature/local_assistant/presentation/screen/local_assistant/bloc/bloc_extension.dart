import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_state.dart';

extension LocalAssistantBlocContextExtension on BuildContext {
  LocalAssistantBloc get bloc => read<LocalAssistantBloc>();

  LocalAssistantState get state => bloc.state;
}
