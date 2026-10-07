import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/widget/force_update_bottom_sheet_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

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
  StreamSubscription<ForceUpdateState>? _blocSubscription;
  bool _isBottomSheetVisible = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    WidgetsBinding.instance.addObserver(this);

    final bloc = appServiceLocator.get<ForceUpdateBloc>();
    _bloc = bloc;

    _blocSubscription = bloc.stream.listen(_onForceUpdateState);
    bloc.add(const CheckForceUpdateEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

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

    rootNavigatorKey.currentState?.pop();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
      _blocSubscription?.cancel();
      _bloc?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
