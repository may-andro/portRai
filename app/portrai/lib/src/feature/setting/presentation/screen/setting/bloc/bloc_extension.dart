import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';

extension ContextExtension on BuildContext {
  SettingBloc get bloc => read<SettingBloc>();

  SettingState get state => bloc.state;
}
