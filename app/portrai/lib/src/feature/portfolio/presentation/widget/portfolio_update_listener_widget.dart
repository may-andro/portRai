import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

/// Refreshes the cached portfolio sections that changed, when the app starts
/// and whenever it comes back to the foreground.
class PortfolioUpdateListenerWidget extends StatefulWidget {
  const PortfolioUpdateListenerWidget({required this.child, super.key});

  final Widget child;

  @override
  State<PortfolioUpdateListenerWidget> createState() =>
      _PortfolioUpdateListenerWidgetState();
}

class _PortfolioUpdateListenerWidgetState
    extends State<PortfolioUpdateListenerWidget>
    with WidgetsBindingObserver {
  late final PortfolioUpdateListenerBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = appServiceLocator.get<PortfolioUpdateListenerBloc>()
      ..add(const PortfolioUpdateCheckRequestedEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _bloc.add(const PortfolioUpdateCheckRequestedEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
