import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/cv_export_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/cv_export_state.dart';

extension ContextExtension on BuildContext {
  CvExportBloc get bloc => read<CvExportBloc>();

  CvExportState get state => bloc.state;
}
