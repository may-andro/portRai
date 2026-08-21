import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state.dart';

extension ContextExtension on BuildContext {
  LocaleSelectionBloc get bloc => read<LocaleSelectionBloc>();

  LocaleSelectionState get state => bloc.state;
}
