import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/job_openings_card_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/job_openings_card_state.dart';

extension ContextExtension on BuildContext {
  JobOpeningsCardBloc get bloc => read<JobOpeningsCardBloc>();

  JobOpeningsCardState get state => bloc.state;
}
