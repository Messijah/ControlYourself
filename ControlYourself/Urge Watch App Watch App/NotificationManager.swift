//
//  NotificationManager.swift
//  Urge Watch App
//
//  Manages local notifications for timer completion
//

import Foundation
import UserNotifications
import WatchKit

class NotificationManager {
    static let shared = NotificationManager()

    private let notificationIdentifier = "urge_timer_complete"

    private init() {
        requestAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Notification

    func scheduleTimerCompleteNotification(at date: Date) {
        // Cancel any existing notifications first
        cancelTimerNotification()

        let content = UNMutableNotificationContent()
        content.title = "Urge Timer Complete"
        content.body = "You're ready to go! Time for the next one."
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETE"

        // Calculate time interval
        let timeInterval = date.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("⚠️ Timer date is in the past, not scheduling notification")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled timer notification for \(date)")
            }
        }
    }

    func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("🔕 Cancelled timer notification")
    }

    // MARK: - Immediate Notification

    func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send immediate notification: \(error.localizedDescription)")
            }
        }
    }
}
