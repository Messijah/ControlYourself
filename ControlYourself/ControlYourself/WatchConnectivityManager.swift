//
//  WatchConnectivityManager.swift
//  ControlYourself
//
//  Manages communication between iPhone and Apple Watch
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Send Data to Watch

    /// Send timer data to Watch
    func sendTimerUpdate(countdownTime: TimeInterval, snusLeft: Int, paniksnusLeft: Int, isReady: Bool, substanceName: String) {
        guard WCSession.default.isReachable else {
            print("❌ Watch not reachable")
            return
        }

        let message: [String: Any] = [
            "countdownTime": countdownTime,
            "snusLeft": snusLeft,
            "paniksnusLeft": paniksnusLeft,
            "isReady": isReady,
            "substanceName": substanceName,
            "timestamp": Date().timeIntervalSince1970
        ]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to send message: \(error.localizedDescription)")
        }

        print("✅ Sent timer update to Watch: countdown=\(countdownTime)s, left=\(snusLeft)")
    }

    /// Update Watch with application context (persistent data)
    func updateContext(countdownTime: TimeInterval, snusLeft: Int, paniksnusLeft: Int, timerEndDate: Date?, substanceName: String) {
        do {
            let context: [String: Any] = [
                "countdownTime": countdownTime,
                "snusLeft": snusLeft,
                "paniksnusLeft": paniksnusLeft,
                "timerEndDate": timerEndDate?.timeIntervalSince1970 ?? 0,
                "substanceName": substanceName
            ]

            try WCSession.default.updateApplicationContext(context)
            print("✅ Updated Watch context")
        } catch {
            print("❌ Failed to update context: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated with state: \(activationState.rawValue)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ WCSession deactivated")
        WCSession.default.activate()
    }
    #endif

    // MARK: - Receive Messages from Watch

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                print("📩 Received action from Watch: \(action)")

                switch action {
                case "takeSnus":
                    // Watch wants to trigger "take snus"
                    // Post notification that iPhone app can listen to
                    NotificationCenter.default.post(name: .takeSnusFromWatch, object: nil)
                    replyHandler(["status": "success"])

                case "usePanic":
                    // Watch wants to use panic snus
                    NotificationCenter.default.post(name: .usePanicFromWatch, object: nil)
                    replyHandler(["status": "success"])

                case "requestUpdate":
                    // Watch requests current state
                    // Reply will be handled by SnusManager
                    NotificationCenter.default.post(name: .watchRequestsUpdate, object: nil)
                    replyHandler(["status": "updating"])

                default:
                    replyHandler(["status": "unknown_action"])
                }
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📩 Received application context from Watch")
        // Handle context updates if needed
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let takeSnusFromWatch = Notification.Name("takeSnusFromWatch")
    static let usePanicFromWatch = Notification.Name("usePanicFromWatch")
    static let watchRequestsUpdate = Notification.Name("watchRequestsUpdate")
}
