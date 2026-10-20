import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_bloc.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/sign_in_state.dart';

extension ContextExtension on BuildContext {
  SignInBloc get bloc => read<SignInBloc>();

  SignInState get state => bloc.state;
}
