import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/connectivity_bloc.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/connectivity_state.dart';

extension ContextExtension on BuildContext {
  ConnectivityBloc get bloc => read<ConnectivityBloc>();

  ConnectivityState get state => bloc.state;
}
