import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';

import '../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';

/// Provides the app-wide [LocalAssistantBloc] that screens hosting the assistant
/// settings card expect to find above them.
class LocalAssistantBlocScope extends StatefulWidget {
  const LocalAssistantBlocScope({
    super.key,
    required this.child,
    this.state = const LocalAssistantState(),
  });

  final Widget child;
  final LocalAssistantState state;

  @override
  State<LocalAssistantBlocScope> createState() =>
      _LocalAssistantBlocScopeState();
}

class _LocalAssistantBlocScopeState extends State<LocalAssistantBlocScope> {
  late final _bloc = MockLocalAssistantBloc()..stubState(widget.state);

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocalAssistantBloc>.value(
      value: _bloc,
      child: widget.child,
    );
  }
}
