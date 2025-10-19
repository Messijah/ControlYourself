//
//  SnusTimerActivity.swift
//  ControlYourself
//
//  Live Activity for Dynamic Island
//

import Foundation
import ActivityKit

// MARK: - Activity Attributes
struct SnusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endDate: Date
        var isReady: Bool
        var snusLeft: Int
        var progress: Double
        var celebrationMessage: String?
        var substanceName: String // e.g., "snus" or "cigaretter"

        init(endDate: Date, isReady: Bool, snusLeft: Int, totalTime: TimeInterval, celebrationMessage: String? = nil, substanceName: String = "snus") {
            self.endDate = endDate
            self.isReady = isReady
            self.snusLeft = snusLeft
            self.celebrationMessage = celebrationMessage
            self.substanceName = substanceName
            // Calculate progress (0.0 to 1.0) based on time remaining
            let timeRemaining = max(0, endDate.timeIntervalSinceNow)
            if totalTime > 0 {
                // Progress goes from 0 (just started) to 1 (completed)
                self.progress = max(0, min(1, (totalTime - timeRemaining) / totalTime))
            } else {
                self.progress = isReady ? 1.0 : 0.0
            }
        }
    }

    var startTime: Date
    var totalTime: TimeInterval
}
