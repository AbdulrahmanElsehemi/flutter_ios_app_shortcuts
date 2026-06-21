import AppIntents
import UIKit

// MARK: - Search Intent

@available(iOS 16, *)
struct OpenSearchIntent: AppIntent {
    static var title: LocalizedStringResource = "Search"
    static var description = IntentDescription("Open the search screen.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Open the custom URL scheme. SceneDelegate.scene(_:openURLContexts:)
        // will receive this URL and call FlutterIosAppShortcutsPlugin.handleURLContexts.
        await UIApplication.shared.open(URL(string: "exampleapp://search")!)
        return .result()
    }
}

// MARK: - Profile Intent

@available(iOS 16, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Profile"
    static var description = IntentDescription("Open the profile screen.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await UIApplication.shared.open(URL(string: "exampleapp://profile")!)
        return .result()
    }
}

// MARK: - Shortcuts Provider

@available(iOS 16, *)
struct ExampleAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenSearchIntent(),
            phrases: ["\(.applicationName) search", "Search \(.applicationName)"],
            shortTitle: "Search",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenProfileIntent(),
            phrases: ["\(.applicationName) profile", "Open my profile in \(.applicationName)"],
            shortTitle: "Profile",
            systemImageName: "person.fill"
        )
    }
}
