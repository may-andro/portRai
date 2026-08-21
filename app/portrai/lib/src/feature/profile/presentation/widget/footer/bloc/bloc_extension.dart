import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_state.dart';

extension FooterContextExtension on BuildContext {
  FooterBloc get bloc => read<FooterBloc>();

  FooterState get state => bloc.state;
}
