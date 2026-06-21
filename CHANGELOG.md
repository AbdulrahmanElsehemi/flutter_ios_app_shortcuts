## 0.1.0

* Initial release.
* Cold-start App Shortcut detection via UserDefaults + MethodChannel.
* Warm-start handling via EventChannel (no external dependencies).
* `AppShortcutService` singleton with `initialize`, `captureInitialShortcut`, `handleInitialShortcut`, and `startListening`.
* `AppShortcutConfig` for navigator key, base route, and route map.
* `FlutterIosAppShortcutsPlugin` static helpers for SceneDelegate integration.
* Example app demonstrating two shortcuts (Search, Profile).
