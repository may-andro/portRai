import 'package:flutter/widgets.dart';

/// Global key for the app's current root [Navigator], created by [GoRouter].
///
/// Some widgets (e.g. those wrapping the `MaterialApp.router` `builder`)
/// sit above the router's navigator in the widget tree and therefore can't
/// rely on their own [BuildContext] to open dialogs/bottom sheets. They can
/// use `rootNavigatorKey.currentContext` instead.
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Creates a new [rootNavigatorKey] for a newly created router.
///
/// A new key is required for every router: the app rebuilds its router when
/// the locale changes, and reusing a [GlobalKey] would let Flutter carry the
/// old [Navigator] state (and its already-loaded screens) over to the new
/// router instead of restarting navigation with freshly loaded content.
GlobalKey<NavigatorState> createRootNavigatorKey() {
  return _rootNavigatorKey = GlobalKey<NavigatorState>();
}
