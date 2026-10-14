import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_state.dart';

extension ContextExtension on BuildContext {
  DesignSystemBloc get bloc => read<DesignSystemBloc>();

  DesignSystemState get state => bloc.state;
}
