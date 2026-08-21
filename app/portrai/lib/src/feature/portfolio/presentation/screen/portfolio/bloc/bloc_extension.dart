import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_state.dart';

extension ContextExtension on BuildContext {
  PortfolioBloc get bloc => read<PortfolioBloc>();

  PortfolioState get state => bloc.state;
}
