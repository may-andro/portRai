import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

import '../mock/feature/assistant/presentation/screen/assistant/bloc/mock_assistant_bloc.dart';

/// Provides the app-wide [AssistantBloc] that screens hosting the assistant
/// settings card expect to find above them.
class AssistantBlocScope extends StatefulWidget {
  const AssistantBlocScope({super.key, required this.child});

  final Widget child;

  @override
  State<AssistantBlocScope> createState() => _AssistantBlocScopeState();
}

class _AssistantBlocScopeState extends State<AssistantBlocScope> {
  late final _bloc = MockAssistantBloc()..stubState(const AssistantState());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssistantBloc>.value(value: _bloc, child: widget.child);
  }
}
