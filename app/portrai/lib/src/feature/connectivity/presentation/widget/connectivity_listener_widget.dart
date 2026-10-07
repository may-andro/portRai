import 'package:flutter/material.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/connectivity/presentation/widget/no_internet_banner_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

/// Shows a bottom banner over [child] while the internet is unavailable.
class ConnectivityListenerWidget extends StatelessWidget {
  const ConnectivityListenerWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityBloc>(
      create: (_) =>
          appServiceLocator.get<ConnectivityBloc>()
            ..add(const StartConnectivityMonitoringEvent()),
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        buildWhen: (previous, current) =>
            (previous is ConnectivityOfflineState) !=
            (current is ConnectivityOfflineState),
        builder: (context, state) {
          final isOffline = state is ConnectivityOfflineState;
          return Stack(
            children: [
              child,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  offset: isOffline ? Offset.zero : const Offset(0, 1),
                  child: isOffline
                      ? const NoInternetBannerWidget()
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
