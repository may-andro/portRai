import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/bloc/feature_flag_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/feature_flag/bloc/feature_flag_state.dart';

extension ContextExtension on BuildContext {
  FeatureFlagBloc get bloc => read<FeatureFlagBloc>();

  FeatureFlagState get state => bloc.state;
}
