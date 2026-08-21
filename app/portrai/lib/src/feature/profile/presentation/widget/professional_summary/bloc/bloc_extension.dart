import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_state.dart';

extension ContextExtension on BuildContext {
  ProfessionalSummaryBloc get bloc => read<ProfessionalSummaryBloc>();

  ProfessionalSummaryState get state => bloc.state;
}
