import Flutter
import flutter_ios_app_shortcuts
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FlutterIosAppShortcutsPlugin.registerIntentActions([
            "OpenSearchIntent": "search",
            "OpenProfileIntent": "profile",
        ])
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
