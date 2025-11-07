import UIKit
import RollbarNotifier

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRollbar()
        setupErrorTracking()
        setupAnalytics()
        setupUserIdentity()
        setupAppearance()
        setupUsageTracking()
        reportAppStarted()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Setup Methods

    private func setupRollbar() {
        guard !Configuration.Analytics.rollbarReportingId.isEmpty else { return }

        let config = RollbarConfig.mutableConfig(
            withAccessToken: Configuration.Analytics.rollbarReportingId,
            environment: Configuration.getEnvironment())
        config.loggingOptions.codeVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        config.loggingOptions.captureIp = RollbarCaptureIpType.anonymize
        config.server.host = UIDevice.current.identifierForVendor?.uuidString

        // Critical: Enable crash reporting
        config.loggingOptions.crashLevel = RollbarLevel.error
        config.loggingOptions.logLevel = RollbarLevel.info

        // Enable all telemetry
        config.telemetry.enabled = true
        config.telemetry.captureLog = true
        config.telemetry.captureConnectivity = true

        // Initialize with crash reporting
        Rollbar.initWithConfiguration(config)
    }

    private func setupErrorTracking() {
        // Initialize error tracker and set up exception handlers
        ErrorTracker.shared.setupExceptionHandlers()
    }

    private func setupAnalytics() {
        // Configure analytics providers with API keys from Configuration
        AnalyticsManager.shared.configure(
            postHogApiKey: Configuration.Analytics.postHogApiKey,
            postHogHost: Configuration.Analytics.postHogHost,
            mixpanelToken: Configuration.Analytics.mixpanelToken
        )
    }

    private func setupUserIdentity() {
        // Initialize user identity (this must come after analytics configuration)
        UserIdentityManager.shared.initializeUser()
        UserIdentityManager.shared.trackFirstLaunchEvents()
        UserIdentityManager.shared.trackAppLaunch()
    }

    private func setupAppearance() {
        // Apply initial appearance
        AppSettings.shared.applyAppearance()
    }

    private func setupUsageTracking() {
        // Track app launch with usage tracker
        UsageTracker.shared.incrementAppLaunches()
    }

    private func reportAppStarted() {
        #if false
        Rollbar.infoMessage("App initialized", data: nil, context: nil)
        #endif
    }
}
