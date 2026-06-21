import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ios_app_shortcuts/flutter_ios_app_shortcuts.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppShortcutConfig', () {
    test('stores all fields correctly', () {
      final key = GlobalKey<NavigatorState>();
      final config = AppShortcutConfig(
        navigatorKey: key,
        baseRoute: '/home',
        routeMap: {'search': '/search', 'profile': '/profile'},
      );

      expect(config.navigatorKey, key);
      expect(config.baseRoute, '/home');
      expect(config.routeMap['search'], '/search');
    });
  });

  group('AppShortcutService', () {
    test('singleton returns same instance', () {
      expect(
        AppShortcutService.instance,
        same(AppShortcutService.instance),
      );
    });

    test('hasShortcutLaunch is false before any capture', () {
      expect(AppShortcutService.instance.hasShortcutLaunch, isFalse);
    });
  });
}
