import Foundation
import UIKit
import CoreData
import SwiftUI

class UserIdentityManager {
    static let shared = UserIdentityManager()

    private let userDefaults = UserDefaults.standard
    private let userIdKey = "TemplateSwiftApp_user_id"
    private let installationDateKey = "TemplateSwiftApp_installation_date"
    private let userPropertiesKey = "TemplateSwiftApp_user_properties"

    private var _currentUserId: String?

    private init() {}

    var currentUserId: String {
        if let cachedId = _currentUserId {
            return cachedId
        }

        if let existingId = userDefaults.string(forKey: userIdKey) {
            _currentUserId = existingId
            return existingId
        }

        let newId = generateUserId()
        userDefaults.set(newId, forKey: userIdKey)
        _currentUserId = newId

        setInitialUserProperties()

        return newId
    }

    var installationDate: Date {
        if let timestamp = userDefaults.object(forKey: installationDateKey) as? Date {
            return timestamp
        }

        let now = Date()
        userDefaults.set(now, forKey: installationDateKey)
        return now
    }

    func initializeUser() {
        let userId = currentUserId

        AnalyticsManager.shared.identify(userId: userId, properties: getUserProperties())

        print("🆔 User initialized with ID: \(userId)")
    }

    func getUserProperties() -> [String: Any] {
        var properties = [String: Any]()

        properties["installation_date"] = installationDate.timeIntervalSince1970
        properties["platform"] = "ios"
        properties["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        properties["build_number"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"

        if let device = UIDevice.current.model as String? {
            properties["device_model"] = device
        }

        if let osVersion = UIDevice.current.systemVersion as String? {
            properties["os_version"] = osVersion
        }

        properties["timezone"] = TimeZone.current.identifier
        properties["locale"] = Locale.current.identifier

        // Add ParPlay-specific properties
        properties["total_launches"] = UsageTracker.shared.launches

        if let storedProperties = userDefaults.dictionary(forKey: userPropertiesKey) {
            properties.merge(storedProperties) { _, new in new }
        }

        return properties
    }

    func setUserProperty(_ key: String, value: Any) {
        var properties = userDefaults.dictionary(forKey: userPropertiesKey) ?? [:]
        properties[key] = value
        userDefaults.set(properties, forKey: userPropertiesKey)

        AnalyticsManager.shared.setUserProperties([key: value])
    }

    func setUserProperties(_ properties: [String: Any]) {
        var storedProperties = userDefaults.dictionary(forKey: userPropertiesKey) ?? [:]
        storedProperties.merge(properties) { _, new in new }
        userDefaults.set(storedProperties, forKey: userPropertiesKey)

        AnalyticsManager.shared.setUserProperties(properties)
    }

    func resetUserIdentity() {
        _currentUserId = nil
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.removeObject(forKey: userPropertiesKey)

        AnalyticsManager.shared.reset()

        initializeUser()

        print("🆔 User identity reset")
    }

    func isFirstLaunch() -> Bool {
        let firstLaunchKey = "TemplateSwiftApp_first_launch"

        if userDefaults.bool(forKey: firstLaunchKey) {
            return false
        }

        userDefaults.set(true, forKey: firstLaunchKey)
        return true
    }

    private func generateUserId() -> String {
        return UUID().uuidString.lowercased()
    }

    private func setInitialUserProperties() {
        let initialProperties: [String: Any] = [
            "user_type": "anonymous",
            "registration_method": "automatic",
            "first_launch": true
        ]

        setUserProperties(initialProperties)
    }
}

// MARK: - ParPlay-specific Extensions
extension UserIdentityManager {
    func trackFirstLaunchEvents() {
        if isFirstLaunch() {
            AnalyticsManager.shared.track("app_first_launch", properties: [
                "installation_date": installationDate.timeIntervalSince1970,
                "platform": "ios"
            ])

            setUserProperty("first_launch_completed", value: true)
        }
    }

    func trackAppLaunch() {
        AnalyticsManager.shared.track("app_launch", properties: [
            "launch_time": Date().timeIntervalSince1970,
            "user_id": currentUserId
        ])
    }

    func trackUserMilestone(_ milestone: String, properties: [String: Any] = [:]) {
        var eventProperties = properties
        eventProperties["milestone"] = milestone
        eventProperties["user_id"] = currentUserId

        AnalyticsManager.shared.track("user_milestone", properties: eventProperties)

        setUserProperty("last_milestone", value: milestone)
        setUserProperty("last_milestone_date", value: Date().timeIntervalSince1970)
    }
}
