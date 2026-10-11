import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

import '../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';
import '../mock/feature/remote_assistant/presentation/screen/remote_assistant/bloc/mock_remote_assistant_bloc.dart';

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
  late final _remoteBloc = MockRemoteAssistantBloc()
    ..stubState(
      const RemoteAssistantState(status: RemoteAssistantStatus.unavailable),
    );

  @override
  void dispose() {
    _bloc.close();
    _remoteBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalAssistantBloc>.value(value: _bloc),
        BlocProvider<RemoteAssistantBloc>.value(value: _remoteBloc),
      ],
      child: widget.child,
    );
  }
}
