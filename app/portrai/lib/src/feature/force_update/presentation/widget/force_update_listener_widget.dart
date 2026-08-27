import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/widget/force_update_bottom_sheet_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

/// Wraps [child] and checks whether the running app version is below the
/// configured `minimumRequiredAppVersion` - once at startup, and again every
/// time the app is resumed (e.g. after the user comes back from the store
/// having updated the app).
///
/// When an update is required, a non-dismissible bottom sheet is shown on
/// top of the app (using [rootNavigatorKey], since this widget sits above
/// the app's [Navigator] in the widget tree) blocking further use until the
/// user updates the app. The sheet is automatically dismissed once a
/// re-check confirms the update requirement is no longer met.
///
/// No-op on web (`kIsWeb`): there's no app store to send a browser user to
/// and no installed binary to update - a page refresh always serves the
/// latest deployed version, so the concept doesn't apply.
class ForceUpdateListenerWidget extends StatefulWidget {
  const ForceUpdateListenerWidget({required this.child, super.key});

  final Widget child;

  @override
  State<ForceUpdateListenerWidget> createState() =>
      _ForceUpdateListenerWidgetState();
}

class _ForceUpdateListenerWidgetState extends State<ForceUpdateListenerWidget>
    with WidgetsBindingObserver {
  ForceUpdateBloc? _bloc;
  bool _isBottomSheetVisible = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    WidgetsBinding.instance.addObserver(this);

    final bloc = appServiceLocator.get<ForceUpdateBloc>();
    _bloc = bloc;

    bloc.stream.listen(_onForceUpdateState);
    bloc.add(const CheckForceUpdateEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Re-check when the app is resumed, e.g. after the user comes back from
    // the store having updated the app.
    if (state == AppLifecycleState.resumed) {
      _bloc?.add(const CheckForceUpdateEvent());
    }
  }

  void _onForceUpdateState(ForceUpdateState state) {
    if (state is ForceUpdateRequiredState) {
      _showBottomSheet();
    } else if (state is ForceUpdateNotRequiredState) {
      _dismissBottomSheet();
    }
  }

  void _showBottomSheet() {
    final bloc = _bloc;
    if (_isBottomSheetVisible || bloc == null) return;

    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isBottomSheetVisible = true;
    ForceUpdateBottomSheetWidget.show(navigatorContext, bloc: bloc).then((_) {
      _isBottomSheetVisible = false;
    });
  }

  void _dismissBottomSheet() {
    if (!_isBottomSheetVisible) return;

    // Use `pop()` (not `maybePop()`) since the sheet's PopScope has
    // `canPop: false` to block the user from dismissing it manually - this
    // programmatic dismissal should still go through.
    rootNavigatorKey.currentState?.pop();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
      _bloc?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
