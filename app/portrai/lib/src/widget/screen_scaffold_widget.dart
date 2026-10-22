import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

/// The frame of a screen: provides its bloc [B] from the service locator,
/// calls [onResume] each time the screen becomes visible, calls [listener]
/// for one-off state effects, and shows [body] in a [Scaffold].
///
/// The bloc is created per screen and closed with it, unless [isRetained] is
/// true: then the locator's shared bloc is used and stays open after the
/// screen closes.
class ScreenScaffoldWidget<B extends StateStreamableSource<S>, S>
    extends StatelessWidget {
  const ScreenScaffoldWidget({
    required this.body,
    this.onCreate,
    this.onResume,
    this.listenWhen,
    this.listener,
    this.isRetained = false,
    this.hasScaffold = true,
    this.appBar,
    this.backgroundColor,
    this.drawer,
    this.onDrawerChanged,
    this.floatingActionButton,
    super.key,
  }) : assert(
         !isRetained || onCreate == null,
         'A retained bloc is shared, so add its events in onResume instead',
       );

  final Widget body;

  /// Called once with the new bloc, typically to add its start event. Not
  /// available with [isRetained].
  final ValueChanged<B>? onCreate;

  /// Called with the bloc each time the screen becomes visible.
  final ValueChanged<B>? onResume;

  final BlocListenerCondition<S>? listenWhen;
  final BlocWidgetListener<S>? listener;

  /// Uses the locator's shared bloc and leaves it open when the screen closes.
  final bool isRetained;

  /// Shows [body] without a [Scaffold], for screens shown inside a dialog.
  final bool hasScaffold;

  final PreferredSizeWidget? appBar;

  /// Defaults to the design system background.
  final DSColor? backgroundColor;
  final Widget? drawer;
  final void Function(B bloc, bool isOpened)? onDrawerChanged;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final child = Builder(builder: _buildScreen);
    if (isRetained) {
      return BlocProvider<B>.value(
        value: appServiceLocator.get<B>(),
        child: child,
      );
    }
    return BlocProvider<B>(
      create: (_) {
        final bloc = appServiceLocator.get<B>();
        onCreate?.call(bloc);
        return bloc;
      },
      child: child,
    );
  }

  Widget _buildScreen(BuildContext context) {
    final bloc = context.read<B>();
    Widget screen = hasScaffold
        ? Scaffold(
            appBar: appBar,
            backgroundColor:
                (backgroundColor ?? context.colorPalette.background).color,
            drawer: drawer,
            drawerEnableOpenDragGesture: false,
            onDrawerChanged: onDrawerChanged == null
                ? null
                : (isOpened) => onDrawerChanged!(bloc, isOpened),
            floatingActionButton: floatingActionButton,
            body: body,
          )
        : body;
    final listener = this.listener;
    if (listener != null) {
      screen = BlocListener<B, S>(
        listenWhen: listenWhen,
        listener: listener,
        child: screen,
      );
    }
    final onResume = this.onResume;
    if (onResume == null) return screen;
    return RouteObserverWidget(onResume: () => onResume(bloc), child: screen);
  }
}
