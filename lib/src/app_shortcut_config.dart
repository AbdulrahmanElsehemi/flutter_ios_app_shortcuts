import 'package:flutter/widgets.dart';

/// Configuration for [AppShortcutService].
class AppShortcutConfig {
  const AppShortcutConfig({
    required this.navigatorKey,
    required this.baseRoute,
    required this.routeMap,
  });

  /// The [GlobalKey<NavigatorState>] used by your [MaterialApp].
  ///
  /// ```dart
  /// final navigatorKey = GlobalKey<NavigatorState>();
  ///
  /// MaterialApp(navigatorKey: navigatorKey, ...)
  /// ```
  final GlobalKey<NavigatorState> navigatorKey;

  /// The named route that acts as the "home base" of the app (e.g. your bottom
  /// navigation screen). When a shortcut fires and the current stack does not
  /// have this route at the top, the plugin resets the stack to this route
  /// first and then pushes the shortcut's target on top.
  ///
  /// Example: `'/home'`
  final String baseRoute;

  /// Maps shortcut action strings to named Flutter routes.
  ///
  /// The action string is the URL host from the custom scheme URL your
  /// AppShortcuts.swift opens (e.g. `myapp://search` → action = `"search"`),
  /// or the value you passed to [FlutterIosAppShortcutsPlugin.registerIntentActions].
  ///
  /// Example:
  /// ```dart
  /// routeMap: {
  ///   'search':   '/search',
  ///   'profile':  '/profile',
  ///   'products': '/products',
  /// }
  /// ```
  final Map<String, String> routeMap;
}
