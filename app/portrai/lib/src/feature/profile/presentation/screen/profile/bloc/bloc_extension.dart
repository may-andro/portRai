import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_state.dart';

extension ContextExtension on BuildContext {
  ProfileBloc get bloc => read<ProfileBloc>();

  ProfileState get state => bloc.state;
}
