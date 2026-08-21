import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_state.dart';

extension ContextExtension on BuildContext {
  ServicesBloc get bloc => read<ServicesBloc>();

  ServicesState get state => bloc.state;
}
