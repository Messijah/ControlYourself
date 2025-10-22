//
//  WatchConnectivityManager.swift
//  Urge Watch App
//
//  Manages communication between Apple Watch and iPhone
//

import Foundation
import WatchConnectivity
import Combine
import ClockKit

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var countdownTime: TimeInterval = 0
    @Published var snusLeft: Int = 0
    @Published var paniksnusLeft: Int = 0
    @Published var timerEndDate: Date?
    @Published var substanceName: String = "snus"
    @Published var isConnected: Bool = false

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }

        // Initialize notification manager
        _ = NotificationManager.shared
    }

    var isReady: Bool {
        return countdownTime == 0
    }

    // MARK: - Complication Updates

    private func updateComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
        print("🔄 Updated complications")
    }

    // MARK: - Send Actions to iPhone

    func takeSnus() {
        guard WCSession.default.isReachable else {
            print("❌ iPhone not reachable")
            return
        }

        let message: [String: Any] = ["action": "takeSnus"]

        WCSession.default.sendMessage(message, replyHandler: { response in
            print("✅ Take snus response: \(response)")
        }) { error in
            print("❌ Failed to send take snus: \(error.localizedDescription)")
        }
    }

    func usePanic() {
        guard WCSession.default.isReachable else {
            print("❌ iPhone not reachable")
            return
        }

        let message: [String: Any] = ["action": "usePanic"]

        WCSession.default.sendMessage(message, replyHandler: { response in
            print("✅ Use panic response: \(response)")
        }) { error in
            print("❌ Failed to send use panic: \(error.localizedDescription)")
        }
    }

    func requestUpdate() {
        guard WCSession.default.isReachable else {
            print("❌ iPhone not reachable")
            return
        }

        let message: [String: Any] = ["action": "requestUpdate"]

        WCSession.default.sendMessage(message, replyHandler: { response in
            print("✅ Request update response: \(response)")
        }) { error in
            print("❌ Failed to request update: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("❌ WCSession activation failed: \(error.localizedDescription)")
                self.isConnected = false
            } else {
                print("✅ WCSession activated: \(activationState.rawValue)")
                self.isConnected = (activationState == .activated)

                // Request initial data
                self.requestUpdate()
            }
        }
    }

    // MARK: - Receive Data from iPhone

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            print("📩 Received context from iPhone")

            if let countdownTime = applicationContext["countdownTime"] as? TimeInterval {
                self.countdownTime = countdownTime
            }

            if let snusLeft = applicationContext["snusLeft"] as? Int {
                self.snusLeft = snusLeft
            }

            if let paniksnusLeft = applicationContext["paniksnusLeft"] as? Int {
                self.paniksnusLeft = paniksnusLeft
            }

            if let timerEndDateTimestamp = applicationContext["timerEndDate"] as? TimeInterval,
               timerEndDateTimestamp > 0 {
                self.timerEndDate = Date(timeIntervalSince1970: timerEndDateTimestamp)

                // Schedule notification for timer completion
                NotificationManager.shared.scheduleTimerCompleteNotification(at: self.timerEndDate!)
            } else {
                self.timerEndDate = nil

                // Cancel notification if timer is cleared
                NotificationManager.shared.cancelTimerNotification()
            }

            if let substanceName = applicationContext["substanceName"] as? String {
                self.substanceName = substanceName
            }

            print("✅ Updated from context: countdown=\(self.countdownTime)s, left=\(self.snusLeft)")

            // Update complications with new data
            self.updateComplications()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📩 Received message from iPhone")

            if let countdownTime = message["countdownTime"] as? TimeInterval {
                self.countdownTime = countdownTime
            }

            if let snusLeft = message["snusLeft"] as? Int {
                self.snusLeft = snusLeft
            }

            if let paniksnusLeft = message["paniksnusLeft"] as? Int {
                self.paniksnusLeft = paniksnusLeft
            }

            if let substanceName = message["substanceName"] as? String {
                self.substanceName = substanceName
            }

            // Update complications with new data
            self.updateComplications()
        }
    }
}
