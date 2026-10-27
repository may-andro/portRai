import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/design_system_card_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/design_system_card_state.dart';

extension ContextExtension on BuildContext {
  DesignSystemCardBloc get bloc => read<DesignSystemCardBloc>();

  DesignSystemCardState get state => bloc.state;
}
