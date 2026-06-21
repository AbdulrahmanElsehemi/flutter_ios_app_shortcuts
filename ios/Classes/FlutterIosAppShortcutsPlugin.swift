import Flutter
import UIKit

/// iOS-side implementation of the flutter_ios_app_shortcuts plugin.
///
/// This class does two things:
///   1. Exposes a MethodChannel so Dart can read (and clear) a pending shortcut
///      action that was written to UserDefaults by the host app's SceneDelegate.
///   2. Exposes an EventChannel so Dart receives warm-start shortcut actions
///      immediately, without polling.
///
/// The host app's SceneDelegate must call the two static helpers:
///   - `FlutterIosAppShortcutsPlugin.handleUserActivities(_:)` from
///     `scene(_:willConnectTo:options:)` — cold-start path.
///   - `FlutterIosAppShortcutsPlugin.handleURLContexts(_:)` from
///     `scene(_:openURLContexts:)` — warm-start path.
public class FlutterIosAppShortcutsPlugin: NSObject, FlutterPlugin {

    // MARK: - Channel names (must match Dart constants)

    static let methodChannelName = "flutter_ios_app_shortcuts/methods"
    static let eventChannelName  = "flutter_ios_app_shortcuts/events"

    // MARK: - UserDefaults key

    /// Written by [handleUserActivities] and [handleURLContexts].
    /// Read and cleared by the "getPendingAction" method call.
    public static let userDefaultsKey = "flutter_ios_app_shortcuts_pending_action"

    // MARK: - Intent → action mapping

    /// Populated by [registerIntentActions] before the Flutter engine starts.
    /// Key   = last component of the AppIntent's activityType, e.g. "OpenSearchIntent"
    /// Value = action string Dart receives, e.g. "search"
    private static var intentActionMap: [String: String] = [:]

    // MARK: - Warm-start event sink

    private static var eventSink: FlutterEventSink?

    // MARK: - FlutterPlugin registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: registrar.messenger()
        )

        let instance = FlutterIosAppShortcutsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - Method call handler

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPendingAction":
            let action = UserDefaults.standard.string(forKey: Self.userDefaultsKey)
            UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
            result(action)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Public static helpers for SceneDelegate

    /// Call from `scene(_:willConnectTo:options:)` to capture cold-start
    /// App Shortcut launches. The NSUserActivity for the intent is present in
    /// `connectionOptions.userActivities` when iOS cold-starts the app because
    /// of an AppIntent with `openAppWhenRun = true`.
    public static func handleUserActivities(_ activities: Set<NSUserActivity>) {
        for activity in activities {
            if let action = resolveAction(from: activity.activityType) {
                UserDefaults.standard.set(action, forKey: userDefaultsKey)
                break
            }
        }
    }

    /// Call from `scene(_:openURLContexts:)` to handle warm-start URL opens
    /// triggered by `UIApplication.shared.open()` inside `perform()`.
    /// The action is emitted on the EventChannel so Dart handles it immediately.
    public static func handleURLContexts(_ contexts: Set<UIOpenURLContext>) {
        for ctx in contexts {
            let url = ctx.url
            guard let host = url.host, !host.isEmpty else { continue }
            eventSink?(host)
        }
    }

    // MARK: - Intent action registration

    /// Register your AppIntent type → action mappings before the Flutter engine
    /// starts. Call this from AppDelegate before or inside
    /// `didInitializeImplicitFlutterEngine`.
    ///
    /// - Parameter map: Dictionary where the key is the **last component** of
    ///   your AppIntent's activityType (e.g. `"OpenSearchIntent"`) and the
    ///   value is the action string your Dart code will receive (e.g. `"search"`).
    ///
    /// Example:
    /// ```swift
    /// FlutterIosAppShortcutsPlugin.registerIntentActions([
    ///     "OpenSearchIntent":   "search",
    ///     "OpenProfileIntent":  "profile",
    /// ])
    /// ```
    public static func registerIntentActions(_ map: [String: String]) {
        intentActionMap = map
    }

    // MARK: - Private helpers

    private static func resolveAction(from activityType: String) -> String? {
        let suffix = activityType.components(separatedBy: ".").last ?? activityType
        return intentActionMap[suffix]
    }
}

// MARK: - FlutterStreamHandler

extension FlutterIosAppShortcutsPlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        FlutterIosAppShortcutsPlugin.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        FlutterIosAppShortcutsPlugin.eventSink = nil
        return nil
    }
}
