import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/splash_bloc.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/splash_state.dart';

extension ContextExtension on BuildContext {
  SplashBloc get bloc => read<SplashBloc>();

  SplashState get state => bloc.state;
}
