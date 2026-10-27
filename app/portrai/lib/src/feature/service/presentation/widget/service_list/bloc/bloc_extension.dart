import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/service_list_bloc.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/service_list_state.dart';

extension ContextExtension on BuildContext {
  ServiceListBloc get bloc => read<ServiceListBloc>();

  ServiceListState get state => bloc.state;
}
