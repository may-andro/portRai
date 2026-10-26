import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/portfolio_update_listener_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/portfolio_update_listener_state.dart';

extension PortfolioUpdateListenerContextExtension on BuildContext {
  PortfolioUpdateListenerBloc get bloc => read<PortfolioUpdateListenerBloc>();

  PortfolioUpdateListenerState get state => bloc.state;
}
