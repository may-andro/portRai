import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_state.dart';

extension ContextExtension on BuildContext {
  ServiceBloc get bloc => read<ServiceBloc>();

  ServiceState get state => bloc.state;
}
