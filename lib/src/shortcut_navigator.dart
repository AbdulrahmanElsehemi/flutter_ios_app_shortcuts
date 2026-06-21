import 'dart:async';
import 'package:flutter/widgets.dart';
import 'app_shortcut_config.dart';

/// Internal class that performs the actual navigation when a shortcut fires.
class ShortcutNavigator {
  ShortcutNavigator({required this.config});

  final AppShortcutConfig config;

  Future<void> navigate(String action) async {
    final route = config.routeMap[action];
    if (route == null) return;

    final navigator = await _waitForNavigator();
    if (navigator == null) return;

    final topName = _topRouteName(navigator);

    // Already showing the target screen — nothing to do.
    if (topName == route) return;

    // Reset the stack to baseRoute if we're not already there.
    if (topName != config.baseRoute) {
      navigator.pushNamedAndRemoveUntil(config.baseRoute, (r) => false);
      // Wait for the transition animation before pushing the target.
      // We intentionally do NOT await the pushNamedAndRemoveUntil future —
      // that future only resolves when baseRoute is popped (effectively never).
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }

    config.navigatorKey.currentState?.pushNamed(route);
  }

  String? _topRouteName(NavigatorState navigator) {
    String? name;
    navigator.popUntil((route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  Future<NavigatorState?> _waitForNavigator({
    int tries = 20,
    Duration delay = const Duration(milliseconds: 150),
  }) async {
    for (var i = 0; i < tries; i++) {
      final state = config.navigatorKey.currentState;
      if (state != null) return state;
      await Future<void>.delayed(delay);
    }
    return null;
  }
}
