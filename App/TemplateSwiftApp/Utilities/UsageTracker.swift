import Foundation
import Combine
import StoreKit
import UIKit

class UsageTracker: ObservableObject {
    static let shared = UsageTracker()

    @Published var launches: Int = 0

    private let userDefaults = UserDefaults.standard
    private let launchesKey = "AppLaunches"
    private let lastReviewRequestKey = "LastReviewRequest"

    private init() {
        launches = userDefaults.integer(forKey: launchesKey)
    }

    func incrementAppLaunches() {
        let currentLaunches = userDefaults.integer(forKey: launchesKey)
        userDefaults.set(currentLaunches + 1, forKey: launchesKey)
        launches = currentLaunches + 1
    }

    func shouldRequestReview() -> Bool {
        // Criteria 1: User has used the app at least three times
        guard launches >= Configuration.ReviewRequest.minimumAppLaunches else { return false }

        // Criteria 2: At least a week since last request (or never asked)
        if let lastRequestDate = userDefaults.object(forKey: lastReviewRequestKey) as? Date {
            let weekAgo = Date().addingTimeInterval(-Configuration.ReviewRequest.daysBetweenRequests)
            guard lastRequestDate < weekAgo else { return false }
        }

        return true
    }

    func recordReviewRequest() {
        userDefaults.set(Date(), forKey: lastReviewRequestKey)
    }

    @MainActor
    func requestReviewIfAppropriate() async {
        guard shouldRequestReview() else { return }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 16.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
            recordReviewRequest()
        }
    }
}
