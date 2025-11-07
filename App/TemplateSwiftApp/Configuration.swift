import Foundation

class Configuration {
    enum Analytics {
        static let rollbarReportingId = "" // TODO
        static let mixpanelToken: String? = nil // TODO
        static let postHogApiKey: String? = nil // TODO
        static let postHogHost: String? = "https://us.i.posthog.com" // TODO
    }

    enum App {
        // Add app-specific configuration here
        static let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "TemplateSwiftApp"
        static let supportEmail = "support@example.com" // TODO
        static let surveyURL = "https://example.com" // TODO
        static let privacyPolicyURL = "https://example.com" // TODO
    }

    enum ReviewRequest {
        static let minimumAppLaunches = 7
        static let daysBetweenRequests: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    }

    // MARK: - Environment Detection
    static func getEnvironment() -> String {
        return isDebugEnvironment() ? "development" : "production"
    }

    static func isDebugEnvironment() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

   static func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

// SECURITY NOTES:
// For production apps, consider using:
// 1. .xcconfig files for different environments (Dev, Staging, Prod)
// 2. Info.plist with environment-specific values
// 3. Keychain for sensitive data
// 4. Environment variables during build time
// 5. Never commit real API keys to version control
