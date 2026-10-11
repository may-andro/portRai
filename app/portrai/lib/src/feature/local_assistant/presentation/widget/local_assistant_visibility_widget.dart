import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

/// Rechecks the retained module session without exposing it to the host screen.
class LocalAssistantVisibilityWidget extends StatelessWidget {
  const LocalAssistantVisibilityWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => RouteObserverWidget(
    onResume: () {
      if (appServiceLocator.isRegistered<LocalAssistantBloc>()) {
        appServiceLocator.get<LocalAssistantBloc>().add(
          const LocalAssistantInitializedEvent(),
        );
      }
    },
    child: child,
  );
}
