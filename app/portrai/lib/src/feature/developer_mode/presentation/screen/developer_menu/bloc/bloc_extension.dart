import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_state.dart';

extension ContextExtension on BuildContext {
  DeveloperMenuBloc get bloc => read<DeveloperMenuBloc>();

  DeveloperMenuState get state => bloc.state;
}
