import 'package:flutter/widgets.dart';

/// Global key for the app's root [Navigator], created by [GoRouter].
///
/// Some widgets (e.g. those wrapping the `MaterialApp.router` `builder`)
/// sit above the router's navigator in the widget tree and therefore can't
/// rely on their own [BuildContext] to open dialogs/bottom sheets. They can
/// use `rootNavigatorKey.currentContext` instead.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
