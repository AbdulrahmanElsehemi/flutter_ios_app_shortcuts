import 'dart:async';
import 'package:flutter/services.dart';
import 'app_shortcut_config.dart';
import 'shortcut_navigator.dart';

/// Main entry point for the flutter_ios_app_shortcuts plugin.
///
/// ## Typical usage in `main.dart`
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await AppShortcutService.instance.initialize(
///     config: AppShortcutConfig(
///       navigatorKey: navigatorKey,
///       baseRoute: '/home',
///       routeMap: {
///         'search':  '/search',
///         'profile': '/profile',
///       },
///     ),
///   );
///
///   // Must be called before runApp so the initial route can be decided.
///   await AppShortcutService.instance.captureInitialShortcut();
///
///   runApp(const MyApp());
///
///   // Must be called after runApp so warm-start shortcuts are handled.
///   AppShortcutService.instance.startListening();
/// }
/// ```
///
/// ## In your root widget
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     AppShortcutService.instance.handleInitialShortcut();
///   });
/// }
/// ```
class AppShortcutService {
  AppShortcutService._();

  /// Singleton instance.
  static final AppShortcutService instance = AppShortcutService._();

  static const _methods = MethodChannel('flutter_ios_app_shortcuts/methods');
  static const _events = EventChannel('flutter_ios_app_shortcuts/events');

  AppShortcutConfig? _config;
  ShortcutNavigator? _navigator;
  StreamSubscription<dynamic>? _subscription;

  /// The action string from the cold-start shortcut, if any.
  /// `null` when the app was opened normally (not via a shortcut).
  String? _pendingAction;

  /// `true` when the app was cold-started by an iOS App Shortcut.
  ///
  /// Use this in your root widget to skip onboarding/splash and go straight
  /// to your [AppShortcutConfig.baseRoute]:
  ///
  /// ```dart
  /// final initialRoute = AppShortcutService.instance.hasShortcutLaunch
  ///     ? '/home'
  ///     : '/onboarding';
  /// ```
  bool get hasShortcutLaunch => _pendingAction != null;

  /// Initialises the service with your app's configuration.
  /// Call once from `main()`, after [WidgetsFlutterBinding.ensureInitialized()]
  /// and before [captureInitialShortcut].
  Future<void> initialize({required AppShortcutConfig config}) async {
    _config = config;
    _navigator = ShortcutNavigator(config: config);
  }

  /// Reads the cold-start shortcut action that the native [SceneDelegate]
  /// wrote to UserDefaults before the Dart VM started.
  ///
  /// Must be called **before** [runApp] so that [hasShortcutLaunch] is ready
  /// when your root widget decides its initial route.
  Future<void> captureInitialShortcut() async {
    assert(
      _config != null,
      'Call initialize() before captureInitialShortcut()',
    );
    try {
      final String? action =
          await _methods.invokeMethod<String>('getPendingAction');
      if (action != null && (_config!.routeMap.containsKey(action))) {
        _pendingAction = action;
      }
    } catch (_) {
      // Channel not available (e.g. Android, simulator without setup) — ignore.
    }
  }

  /// Navigates to the cold-start shortcut's target screen.
  ///
  /// Call this from a [WidgetsBinding.addPostFrameCallback] inside your root
  /// widget's [State.initState] so the navigator is fully mounted:
  ///
  /// ```dart
  /// WidgetsBinding.instance.addPostFrameCallback((_) {
  ///   AppShortcutService.instance.handleInitialShortcut();
  /// });
  /// ```
  Future<void> handleInitialShortcut() async {
    final action = _pendingAction;
    if (action == null) return;
    _pendingAction = null;
    await _navigator?.navigate(action);
  }

  /// Starts listening for warm-start shortcuts (app is in the background,
  /// user taps a shortcut).
  ///
  /// Call immediately after [runApp()]. Events arrive via the native
  /// [FlutterIosAppShortcutsPlugin.handleURLContexts] call in SceneDelegate.
  void startListening() {
    _subscription?.cancel();
    _subscription = _events.receiveBroadcastStream().listen(
      (dynamic action) async {
        if (action is String && (_config?.routeMap.containsKey(action) ?? false)) {
          await _navigator?.navigate(action);
        }
      },
      onError: (_) {},
    );
  }

  /// Stops listening for warm-start shortcuts. Call when your app is disposed.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
