import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/personal_summary_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/personal_summary_state.dart';

extension ContextExtension on BuildContext {
  PersonalSummaryBloc get bloc => read<PersonalSummaryBloc>();

  PersonalSummaryState get state => bloc.state;
}
