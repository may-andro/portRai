import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/job_openings_state.dart';

extension ContextExtension on BuildContext {
  JobOpeningsBloc get bloc => read<JobOpeningsBloc>();

  JobOpeningsState get state => bloc.state;
}
