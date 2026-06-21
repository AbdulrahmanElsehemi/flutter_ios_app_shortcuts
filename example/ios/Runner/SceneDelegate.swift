import Flutter
import flutter_ios_app_shortcuts
import UIKit

/// Custom scene delegate that intercepts App Shortcut launches and forwards
/// them to the flutter_ios_app_shortcuts plugin.
///
/// Change `UISceneDelegateClassName` in Info.plist to `Runner.SceneDelegate`.
class SceneDelegate: FlutterSceneDelegate {

    // MARK: - Cold-start

    /// Called once when the scene is first created.
    /// `connectionOptions.userActivities` contains the AppIntent NSUserActivity
    /// when iOS cold-starts the app because of a shortcut with openAppWhenRun = true.
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        FlutterIosAppShortcutsPlugin.handleUserActivities(connectionOptions.userActivities)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    // MARK: - Warm-start

    /// Called when `UIApplication.shared.open()` is invoked inside `perform()`.
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        FlutterIosAppShortcutsPlugin.handleURLContexts(URLContexts)
        super.scene(scene, openURLContexts: URLContexts)
    }
}
