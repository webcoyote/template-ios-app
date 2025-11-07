import SwiftUI

@main
struct TemplateSwiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: .appearanceModeChanged)) { _ in
                    // Appearance is handled by AppSettings.applyAppearance()
                }
        }
    }
}
