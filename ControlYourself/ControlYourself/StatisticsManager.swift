//
//  StatisticsManager.swift
//  ControlYourself
//
//  Created by Claude on 2025-10-16.
//

import Foundation

class StatisticsManager: ObservableObject {
    private let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard

    // MARK: - Track Daily Usage

    func recordDayCompleted() {
        let today = Calendar.current.startOfDay(for: Date())
        var completedDays = getCompletedDays()

        // Add today if not already recorded
        if !completedDays.contains(today) {
            completedDays.append(today)
            saveCompletedDays(completedDays)
        }
    }

    func recordSubstanceTaken() {
        let today = Calendar.current.startOfDay(for: Date())
        var dailyUsage = getDailyUsage()

        // Increment count for today
        dailyUsage[today, default: 0] += 1
        saveDailyUsage(dailyUsage)
    }

    // MARK: - Statistics

    var daysInBalance: Int {
        return getCompletedDays().count
    }

    var averagePerDay: Double {
        let usage = getDailyUsage()
        guard !usage.isEmpty else { return 0 }

        let total = usage.values.reduce(0, +)
        return Double(total) / Double(usage.count)
    }

    var totalSubstancesUsed: Int {
        return getDailyUsage().values.reduce(0, +)
    }

    var currentStreak: Int {
        let completedDays = getCompletedDays().sorted()
        guard !completedDays.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if user has used the app today
        let hasUsedToday = completedDays.contains(today)

        // If user hasn't used the app today, check if they used it yesterday
        // If they missed yesterday, streak is broken (returns 0)
        if !hasUsedToday {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            if !completedDays.contains(yesterday) {
                // User missed yesterday - streak is broken
                return 0
            }
            // User used app yesterday but not today yet - count from yesterday
        }

        // Count streak backwards from either today (if used) or yesterday (if not used today yet)
        var streak = 0
        var currentDate = hasUsedToday ? today : calendar.date(byAdding: .day, value: -1, to: today) ?? today

        for day in completedDays.reversed() {
            if calendar.isDate(day, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Data Management

    private func getCompletedDays() -> [Date] {
        guard let data = defaults.data(forKey: "completedDays"),
              let dates = try? JSONDecoder().decode([Date].self, from: data) else {
            return []
        }
        return dates
    }

    private func saveCompletedDays(_ days: [Date]) {
        if let data = try? JSONEncoder().encode(days) {
            defaults.set(data, forKey: "completedDays")
        }
    }

    private func getDailyUsage() -> [Date: Int] {
        guard let data = defaults.data(forKey: "dailyUsage"),
              let usage = try? JSONDecoder().decode([Date: Int].self, from: data) else {
            return [:]
        }
        return usage
    }

    private func saveDailyUsage(_ usage: [Date: Int]) {
        if let data = try? JSONEncoder().encode(usage) {
            defaults.set(data, forKey: "dailyUsage")
        }
    }

    // MARK: - Reset (for substance change)

    func resetAllStatistics() {
        defaults.removeObject(forKey: "completedDays")
        defaults.removeObject(forKey: "dailyUsage")
    }
}
