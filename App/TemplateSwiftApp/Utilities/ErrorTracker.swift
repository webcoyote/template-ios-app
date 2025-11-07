//
//  ErrorTracker.swift
//  ParPlay
//
//  Created by pat on 7/26/25.
//

import Foundation
import RollbarNotifier

class ErrorTracker {
    static let shared = ErrorTracker()

    private init() {}

    func setupExceptionHandlers() {
        NSSetUncaughtExceptionHandler { exception in
            ErrorTracker.shared.logException(exception)

            // Block for a short time to allow network request to complete
            Thread.sleep(forTimeInterval: 2.0)
        }

        // Also set up signal handlers for crashes that bypass NSException
        signal(SIGABRT) { signal in
            ErrorTracker.shared.handleSignal(signal, name: "SIGABRT")
        }

        signal(SIGILL) { signal in
            ErrorTracker.shared.handleSignal(signal, name: "SIGILL")
        }

        signal(SIGFPE) { signal in
            ErrorTracker.shared.handleSignal(signal, name: "SIGFPE")
        }

        signal(SIGBUS) { signal in
            ErrorTracker.shared.handleSignal(signal, name: "SIGBUS")
        }

        signal(SIGSEGV) { signal in
            ErrorTracker.shared.handleSignal(signal, name: "SIGSEGV")
        }
    }

    func handleSignal(_ signalNumber: Int32, name: String) {
        let userInfo: [String: Any] = [
            "signal": signalNumber,
            "signal_name": name
        ]
        Rollbar.criticalMessage("Signal received: \(name)", data: userInfo, context: "SignalHandler")
        print("🚨 Signal \(name) (\(signalNumber)) caught - logging to Rollbar")

        // Force flush with a shorter timeout since signals are more critical
        Thread.sleep(forTimeInterval: 1.0)  // Give time for the message to be sent

        // Restore default signal handler and re-raise
        signal(signalNumber, SIG_DFL)
        raise(signalNumber)
    }

    func logException(_ exception: NSException) {
        let userInfo: [String: Any] = [
            "name": exception.name.rawValue,
            "reason": exception.reason ?? "No reason provided",
            "userInfo": exception.userInfo ?? [:]
        ]

        Rollbar.criticalMessage("Uncaught Exception", data: userInfo, context: "ErrorTracker")
    }

    func logError(_ error: Error, context: String = "Unknown") {
        let userInfo: [String: Any] = [
            "error": error.localizedDescription,
            "context": context
        ]

        Rollbar.errorMessage("Error occurred", data: userInfo, context: context)
    }

    func logWarning(_ message: String, context: String = "Unknown") {
        Rollbar.warningMessage(message, data: nil, context: context)
    }

    func logInfo(_ message: String, context: String = "Unknown") {
        Rollbar.infoMessage(message, data: nil, context: context)
    }
}
