import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_state.dart';

extension ContextExtension on BuildContext {
  ForceUpdateBloc get bloc => read<ForceUpdateBloc>();

  ForceUpdateState get state => bloc.state;
}
