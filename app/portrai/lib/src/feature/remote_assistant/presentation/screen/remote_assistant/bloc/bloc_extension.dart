import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';

extension RemoteAssistantBlocContextExtension on BuildContext {
  RemoteAssistantBloc get bloc => read<RemoteAssistantBloc>();
  RemoteAssistantState get state => bloc.state;
}
