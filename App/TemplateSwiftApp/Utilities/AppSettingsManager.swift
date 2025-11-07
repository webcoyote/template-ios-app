import UIKit
import UserNotifications
import SwiftUI

extension Notification.Name {
    static let appearanceModeChanged = Notification.Name("appearanceModeChanged")
}

enum AppearanceMode: String, CaseIterable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "Use System Settings"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let userDefaults = UserDefaults.standard
    private let appearanceModeKey = "appearance_mode"
    private let appLaunchesKey = "app_launches"
    private let lastReviewRequestDateKey = "last_review_request_date"

    @Published var appearanceMode: AppearanceMode {
        didSet {
            userDefaults.set(appearanceMode.rawValue, forKey: appearanceModeKey)
            applyAppearance()
            NotificationCenter.default.post(name: .appearanceModeChanged, object: nil)
        }
    }

    var appLaunches: Int {
        get { userDefaults.integer(forKey: appLaunchesKey) }
        set { userDefaults.set(newValue, forKey: appLaunchesKey) }
    }

    var lastReviewRequestDate: Date? {
        get { userDefaults.object(forKey: lastReviewRequestDateKey) as? Date }
        set { userDefaults.set(newValue, forKey: lastReviewRequestDateKey) }
    }

    private init() {
        // Load initial values from UserDefaults
        let savedAppearanceMode: AppearanceMode
        if let rawValue = userDefaults.string(forKey: appearanceModeKey),
           let mode = AppearanceMode(rawValue: rawValue) {
            savedAppearanceMode = mode
        } else {
            savedAppearanceMode = .system
        }

        // Initialize published properties
        appearanceMode = savedAppearanceMode
    }

    func applyAppearance() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }

            window.overrideUserInterfaceStyle = self.appearanceMode.interfaceStyle
        }
    }

    func getAppInfo() -> (name: String, version: String, build: String) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Configuration.App.appName
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return (appName, appVersion, buildNumber)
    }

    func getDeviceInfo() -> String {
        let deviceModel = UIDevice.current.model
        let deviceName = UIDevice.current.name
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let appInfo = getAppInfo()

        return """
App: \(appInfo.name)
Version: \(appInfo.version).\(appInfo.build)
Device: \(deviceName)
Model: \(deviceModel)
OS: \(systemName) \(systemVersion)
"""
    }

    func incrementAppLaunches() {
        appLaunches += 1
    }

}

typealias AppSettingsManager = AppSettings
