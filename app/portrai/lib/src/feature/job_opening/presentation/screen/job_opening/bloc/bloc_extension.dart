import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/job_opening_state.dart';

extension ContextExtension on BuildContext {
  JobOpeningBloc get bloc => read<JobOpeningBloc>();

  JobOpeningState get state => bloc.state;
}
