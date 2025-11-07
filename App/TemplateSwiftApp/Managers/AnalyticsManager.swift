import Foundation
import UIKit
import PostHog
import Mixpanel

// MARK: - Analytics Event Protocol
protocol AnalyticsEvent {
    var name: String { get }
    var properties: [String: Any]? { get }
}

// MARK: - User Properties Protocol
protocol UserProperties {
    var properties: [String: Any] { get }
}

// MARK: - Analytics Provider Protocol
protocol AnalyticsProvider {
    func track(event: String, properties: [String: Any]?)
    func identify(userId: String, properties: [String: Any]?)
    func setUserProperties(_ properties: [String: Any])
    func reset()
    func flush()
}

// MARK: - Provider Implementations
class PostHogProvider: AnalyticsProvider {
    private let posthog: PostHogSDK

    init(apiKey: String, host: String, isDebug: Bool = false) {
        let config = PostHogConfig(apiKey: apiKey, host: host)
        config.captureApplicationLifecycleEvents = true
        config.captureScreenViews = true

        // Configure debug settings
        if isDebug {
            config.flushAt = 1 // Flush immediately in debug mode
            config.flushIntervalSeconds = 1 // More frequent flushing
        }

        self.posthog = PostHogSDK.with(config)
    }

    func track(event: String, properties: [String: Any]?) {
        posthog.capture(event, properties: properties)
    }

    func identify(userId: String, properties: [String: Any]?) {
        posthog.identify(userId, userProperties: properties)
    }

    func setUserProperties(_ properties: [String: Any]) {
        // PostHog uses identify for setting user properties
        // Use distinct ID from PostHog or a default value
        let distinctId = posthog.getDistinctId()
        posthog.identify(distinctId, userProperties: properties)
    }

    func reset() {
        posthog.reset()
    }

    func flush() {
        posthog.flush()
    }
}

class MixpanelProvider: AnalyticsProvider {
    private let mixpanel: MixpanelInstance

    init(token: String, isDebug: Bool = false) {
        self.mixpanel = Mixpanel.initialize(token: token)
        mixpanel.trackAutomaticEventsEnabled = true

        // Configure debug settings
        if isDebug {
            mixpanel.flushInterval = 1.0 // Flush every second in debug
        }
    }

    private func convertToMixpanelType(_ value: Any) -> MixpanelType? {
        if let stringValue = value as? String {
            return stringValue
        } else if let intValue = value as? Int {
            return intValue
        } else if let doubleValue = value as? Double {
            return doubleValue
        } else if let boolValue = value as? Bool {
            return boolValue
        } else if let dateValue = value as? Date {
            return dateValue
        } else if let urlValue = value as? URL {
            return urlValue
        } else if let arrayValue = value as? [MixpanelType] {
            return arrayValue
        } else if let dictValue = value as? [String: MixpanelType] {
            return dictValue
        } else {
            return String(describing: value)
        }
    }

    private func convertProperties(_ properties: [String: Any]) -> [String: MixpanelType] {
        return properties.compactMapValues { convertToMixpanelType($0) }
    }

    func track(event: String, properties: [String: Any]?) {
        let props = properties ?? [:]
        let mixpanelCompatible = convertProperties(props)
        mixpanel.track(event: event, properties: mixpanelCompatible)
    }

    func identify(userId: String, properties: [String: Any]?) {
        mixpanel.identify(distinctId: userId)
        if let properties = properties {
            setUserProperties(properties)
        }
    }

    func setUserProperties(_ properties: [String: Any]) {
        let mixpanelCompatible = convertProperties(properties)
        mixpanel.people.set(properties: mixpanelCompatible)
    }

    func reset() {
        mixpanel.reset()
    }

    func flush() {
        mixpanel.flush()
    }
}

// MARK: - Unified Analytics Manager
class AnalyticsManager {
    static let shared = AnalyticsManager()

    private var providers: [AnalyticsProvider] = []
    private var commonProperties: [String: Any] = [:]
    private var userId: String?

    private init() {}

    // MARK: - Configuration
    func configure(
        postHogApiKey: String? = nil,
        postHogHost: String? = nil,
        mixpanelToken: String? = nil
    ) {
        providers.removeAll()

        let isDebug = Configuration.isDebugEnvironment()

        if let postHogKey = postHogApiKey {
            let host = postHogHost ?? "https://app.posthog.com"
            providers.append(PostHogProvider(apiKey: postHogKey, host: host, isDebug: isDebug))
        }

        if let mixToken = mixpanelToken {
            providers.append(MixpanelProvider(token: mixToken, isDebug: isDebug))
        }

        // Set common properties like app version, device info
        setupCommonProperties()
    }

    private func setupCommonProperties() {
        let isDebug = Configuration.isDebugEnvironment()
        let isSimulator = Configuration.isRunningOnSimulator()

        commonProperties = [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "app_build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "ios_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.model,
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone",
            "is_debug": isDebug,
            "is_simulator": isSimulator,
            "environment": Configuration.getEnvironment(),
            "user_type": getUserType(isDebug: isDebug, isSimulator: isSimulator)
        ]
    }

    private func getUserType(isDebug: Bool, isSimulator: Bool) -> String {
        if isDebug && isSimulator {
            return "debug_simulator"
        } else if isDebug {
            return "debug_device"
        } else if isSimulator {
            return "simulator" // Unlikely in production, but possible
        } else {
            return "production"
        }
    }

    // MARK: - Event Tracking
    func track(_ event: String, properties: [String: Any]? = nil) {
        let mergedProperties = mergeProperties(properties)

        providers.forEach { provider in
            provider.track(event: event, properties: mergedProperties)
        }
    }

    func track(_ event: AnalyticsEvent) {
        track(event.name, properties: event.properties)
    }

    // MARK: - User Management
    func identify(userId: String, properties: [String: Any]? = nil) {
        // Prefix debug user IDs to separate them from production users
        let finalUserId = Configuration.isDebugEnvironment() ? "debug_\(userId)" : userId
        self.userId = finalUserId

        var finalProperties = properties ?? [:]

        // Add debug context to user properties
        if Configuration.isDebugEnvironment() {
            finalProperties["is_debug_user"] = true
            finalProperties["original_user_id"] = userId
        }

        providers.forEach { provider in
            provider.identify(userId: finalUserId, properties: finalProperties)
        }
    }

    func setUserProperties(_ properties: [String: Any]) {
        providers.forEach { provider in
            provider.setUserProperties(properties)
        }
    }

    func setUserProperty(key: String, value: Any) {
        setUserProperties([key: value])
    }

    // MARK: - Session Management
    func reset() {
        userId = nil
        providers.forEach { $0.reset() }
    }

    func flush() {
        providers.forEach { $0.flush() }
    }

    // MARK: - Helper Methods
    private func mergeProperties(_ eventProperties: [String: Any]?) -> [String: Any] {
        var merged = commonProperties
        if let eventProps = eventProperties {
            merged.merge(eventProps) { _, new in new }
        }
        return merged
    }
}

// MARK: - Predefined Events (following standard naming conventions)
extension AnalyticsManager {
    // Authentication Events
    func trackSignUp(method: String, properties: [String: Any]? = nil) {
        var props = properties ?? [:]
        props["method"] = method
        track("sign_up", properties: props)
    }

    func trackLogin(method: String, properties: [String: Any]? = nil) {
        var props = properties ?? [:]
        props["method"] = method
        track("login", properties: props)
    }

    // Onboarding Events
    func trackOnboardingStart() {
        track("onboarding_start")
    }

    func trackOnboardingStep(step: Int, stepName: String? = nil) {
        var props: [String: Any] = ["step": step]
        if let name = stepName {
            props["step_name"] = name
        }
        track("onboarding_step_completed", properties: props)
    }

    func trackOnboardingComplete() {
        track("onboarding_complete")
    }

    // In-App Purchase Events
    func trackPurchaseStart(productId: String, price: Double? = nil) {
        var props: [String: Any] = ["product_id": productId]
        if let price = price {
            props["price"] = price
        }
        track("purchase_started", properties: props)
    }

    func trackPurchaseComplete(productId: String, price: Double, currency: String = "USD") {
        let props: [String: Any] = [
            "product_id": productId,
            "price": price,
            "currency": currency,
            "revenue": price  // Some platforms look for this key
        ]
        track("purchase_completed", properties: props)
    }

    func trackPurchaseFailed(productId: String, error: String) {
        let props: [String: Any] = [
            "product_id": productId,
            "error": error
        ]
        track("purchase_failed", properties: props)
    }

    // Feature Usage Events
    func trackFeatureUsed(featureName: String, properties: [String: Any]? = nil) {
        var props = properties ?? [:]
        props["feature_name"] = featureName
        track("feature_used", properties: props)
    }

    // Screen View Events
    func trackScreenView(screenName: String, properties: [String: Any]? = nil) {
        var props = properties ?? [:]
        props["screen_name"] = screenName
        track("screen_view", properties: props)
    }
}

// MARK: - Usage Examples & Debug Features
/*
// Basic usage:
AnalyticsManager.shared.track("button_clicked", properties: ["button_name": "submit"])

// User identification (automatically handles debug prefixing):
AnalyticsManager.shared.identify(userId: "user123", properties: [
    "email": "user@example.com",
    "subscription_type": "premium"
])

// AUTOMATIC DEBUG FEATURES:
// 
// 1. Environment Detection:
//    - All events automatically include: is_debug, is_simulator, environment, user_type
//    - Debug builds get faster flush intervals for immediate feedback
//
// 2. User Separation:
//    - Debug users get "debug_" prefix (debug_user123 vs user123)
//    - Original ID preserved in user properties for reference
//
// 3. Filtering in Analytics Dashboards:
//    - PostHog: Filter by user_type = "debug_simulator" or environment = "development"
//    - Mixpanel: Use "user_type" property to exclude debug users
//
// 4. Query Examples:
//    - Exclude debug users: user_type != "debug_simulator" AND user_type != "debug_device"
//    - Only production data: environment = "production"
//    - Debug data only: is_debug = true

// Track purchase:
AnalyticsManager.shared.trackPurchaseComplete(
    productId: "premium_monthly",
    price: 9.99,
    currency: "USD"
)

// Track screen views:
AnalyticsManager.shared.trackScreenView(screenName: "home_screen")

// Custom event with structured data:
struct ShareEvent: AnalyticsEvent {
    let name = "content_shared"
    let properties: [String: Any]?
    
    init(contentType: String, method: String) {
        self.properties = [
            "content_type": contentType,
            "share_method": method
        ]
    }
}

AnalyticsManager.shared.track(ShareEvent(contentType: "article", method: "twitter"))
*/
