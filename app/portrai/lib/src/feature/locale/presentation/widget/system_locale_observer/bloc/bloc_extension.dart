import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_state.dart';

extension ContextExtension on BuildContext {
  SystemLocaleObserverBloc get bloc => read<SystemLocaleObserverBloc>();

  SystemLocaleObserverState get state => bloc.state;
}
