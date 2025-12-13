//
//  fastlaneLaunchTests.swift
//  fastlane
//
//  Created for automated screenshot generation
//

import XCTest

final class fastlaneLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Wait for app to be ready
        sleep(2)

        // Capture main screen
        snapshot("0Home")

        // Navigate to Settings if available
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
            snapshot("1Settings")
        }

        // Add more screenshot captures here as needed for your app
        // Example:
        // app.buttons["TabName"].tap()
        // sleep(1)
        // snapshot("2TabName")
    }
}
