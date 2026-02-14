
import Foundation
import Combine
import UserNotifications
import UIKit
import ActivityKit
import WatchConnectivity
import AVFoundation
import AudioToolbox

// MARK: - Notification Names
extension Notification.Name {
    static let takeSnusFromWatch = Notification.Name("takeSnusFromWatch")
    static let usePanicFromWatch = Notification.Name("usePanicFromWatch")
    static let watchRequestsUpdate = Notification.Name("watchRequestsUpdate")
}

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let snusLeft = "snusLeft"
    static let paniksnusLeft = "paniksnusLeft"
    static let paniksnus = "paniksnus"
    static let snusInterval = "snusInterval"
    static let countdownTime = "countdownTime"
    static let dailyGoal = "dailyGoal"
    static let selectedSubstance = "selectedSubstance"
    static let isTimerActive = "isTimerActive"
    static let timerStartTime = "timerStartTime"
    static let hasStartedTimerToday = "hasStartedTimerToday"
    static let hasBeenInitialized = "hasBeenInitialized"
    static let hasConfiguredSettings = "hasConfiguredSettings"
    static let lastActiveTime = "lastActiveTime"
    static let lastSnusTime = "lastSnusTime"
    static let lastResetDate = "lastResetDate"
    static let lastWeekResetDate = "lastWeekResetDate"
    static let isDynamicIslandEnabled = "isDynamicIslandEnabled"
    static let isTimerNotificationEnabled = "isTimerNotificationEnabled"
    // Auto-progression (nedtrappning)
    static let isProgressionEnabled = "isProgressionEnabled"
    static let progressionStartInterval = "progressionStartInterval"     // seconds
    static let progressionTargetInterval = "progressionTargetInterval"   // seconds
    static let progressionWeeks = "progressionWeeks"                     // total weeks
    static let progressionStartDate = "progressionStartDate"            // Date when started
}

class SnusManager: ObservableObject {
    // Shared UserDefaults for App Group
    private static let sharedDefaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard

    @Published var snusLeft: Int
    @Published var paniksnusLeft: Int
    @Published var countdownTime: TimeInterval
    @Published var paniksnus: Int
    @Published var substanceName: String = "snus" // Lowercase substance name for dynamic text (internal identifier)
    @Published var snusInterval: TimeInterval // Tid mellan snusar i sekunder.
    @Published var isProgressionEnabled: Bool = false
    private var timer: Timer?
    private var isTimerRunning: Bool = false
    private var currentActivity: Activity<SnusTimerAttributes>?
    private var timerEndDate: Date? // Track the actual end date to avoid time drift
    private var dailyCheckTimer: Timer? // Timer to check for daily reset

    // Computed property for localized substance name (plural/title form)
    var localizedSubstanceName: String {
        if substanceName.lowercased().contains("cigar") {
            return NSLocalizedString("substance.cigarettes", comment: "")
        } else {
            return NSLocalizedString("substance.snus", comment: "")
        }
    }

    // Computed property for localized substance name in singular form (for use in sentences)
    var localizedSubstanceNameSingular: String {
        if substanceName.lowercased().contains("cigar") {
            return NSLocalizedString("substance.cigarettes_singular", comment: "")
        } else {
            return NSLocalizedString("substance.snus_singular", comment: "")
        }
    }

    // Public computed property to access timer end date for UI
    var currentTimerEndDate: Date? {
        if countdownTime == 0 {
            return nil
        }
        return timerEndDate ?? Date().addingTimeInterval(countdownTime)
    }

    // Celebration messages for when timer completes - dynamically generated based on substance
    private func celebrationMessages() -> [String] {
        return [
            String(format: NSLocalizedString("celebration.substance_time", comment: ""), localizedSubstanceNameSingular),
            NSLocalizedString("celebration.well_done", comment: ""),
            String(format: NSLocalizedString("celebration.enjoy_substance", comment: ""), localizedSubstanceNameSingular),
            NSLocalizedString("celebration.its_time", comment: ""),
            NSLocalizedString("celebration.take_one_now", comment: ""),
            NSLocalizedString("celebration.ready", comment: ""),
            NSLocalizedString("celebration.ready_to_enjoy", comment: ""),
            NSLocalizedString("celebration.perfect_timing", comment: "")
        ]
    }

    // Encouragement messages for waiting state (used in Live Activity)
    private func encouragementMessages() -> [String] {
        return [
            NSLocalizedString("encouragement.you_can_do_it", comment: ""),
            NSLocalizedString("encouragement.hold_on", comment: ""),
            NSLocalizedString("encouragement.good_job", comment: ""),
            NSLocalizedString("encouragement.keep_going", comment: ""),
            NSLocalizedString("encouragement.you_are_strong", comment: "")
        ]
    }

    init() {
        let defaults = SnusManager.sharedDefaults

        // Check if this is the first launch
        let hasBeenInitialized = defaults.bool(forKey: UserDefaultsKeys.hasBeenInitialized)

        if hasBeenInitialized {
            // Load saved values with minimum bounds
            self.paniksnus = max(1, defaults.integer(forKey: UserDefaultsKeys.paniksnus))
            self.snusLeft = defaults.integer(forKey: UserDefaultsKeys.snusLeft)  // 0 is valid here
            self.paniksnusLeft = defaults.integer(forKey: UserDefaultsKeys.paniksnusLeft)  // 0 is valid here
            self.snusInterval = max(900, defaults.double(forKey: UserDefaultsKeys.snusInterval))  // Minimum 15 minutes (900 seconds)

            // DON'T load countdownTime from UserDefaults yet - will be calculated later
            // based on whether timer is active or if we've started today
            self.countdownTime = 0  // Temporary value, will be set correctly below
        } else {
            // First launch - use default values
            self.paniksnus = 5
            self.snusLeft = 10
            self.paniksnusLeft = 5
            self.snusInterval = 7200  // 2 hours in seconds
            self.countdownTime = 0  // Start at 0, wait for user to press "Start day"

            // Mark as initialized
            defaults.set(true, forKey: UserDefaultsKeys.hasBeenInitialized)
        }

        // Load auto-progression state
        self.isProgressionEnabled = defaults.bool(forKey: UserDefaultsKeys.isProgressionEnabled)

        // Load selected substance name
        if let savedSubstance = defaults.string(forKey: UserDefaultsKeys.selectedSubstance) {
            self.substanceName = savedSubstance.lowercased()
        } else {
            // If no substance saved yet but app is configured, default to "snus"
            // This handles migration for existing users
            self.substanceName = "snus"
        }

        // Initialize lastResetDate if it doesn't exist
        if defaults.object(forKey: UserDefaultsKeys.lastResetDate) == nil {
            defaults.set(Date(), forKey: UserDefaultsKeys.lastResetDate)
        }

        // Initialize lastWeekResetDate if it doesn't exist
        if defaults.object(forKey: UserDefaultsKeys.lastWeekResetDate) == nil {
            defaults.set(Date(), forKey: UserDefaultsKeys.lastWeekResetDate)
        }

        // If timer wasn't active, check if we've started today and load countdown time
        if !defaults.bool(forKey: UserDefaultsKeys.isTimerActive) {
            let hasStartedToday = defaults.bool(forKey: UserDefaultsKeys.hasStartedTimerToday)
            if hasStartedToday {
                // Load saved countdown time
                self.countdownTime = defaults.double(forKey: UserDefaultsKeys.countdownTime)
            } else {
                // Haven't started today - countdown should be 0 (ready to start)
                self.countdownTime = 0
            }
        } else if let timerStartTime = defaults.object(forKey: UserDefaultsKeys.timerStartTime) as? Date {
            // Timer was active - calculate remaining time but DON'T start countdown yet
            let timePassed = Date().timeIntervalSince(timerStartTime)
            let remainingTime = self.snusInterval - timePassed

            if remainingTime > 0 {
                self.countdownTime = remainingTime
                self.timerEndDate = timerStartTime.addingTimeInterval(self.snusInterval)
                // Re-schedule notification for timer end (in case app was killed/restarted)
                scheduleTimerEndNotification(at: self.timerEndDate!)
            } else {
                // Timer completed - update all settings to maintain consistency
                self.countdownTime = 0
                self.timerEndDate = nil
                defaults.set(false, forKey: UserDefaultsKeys.isTimerActive)
                defaults.set(0, forKey: UserDefaultsKeys.countdownTime)
                // IMPORTANT: Save all settings to prevent state desync
                self.saveSettings()
            }
        }

        setupNotifications()
        requestNotificationPermissions()

        // Check for daily/weekly reset on app launch
        checkForDailyReset()

        // Setup Watch Connectivity listeners
        setupWatchConnectivity()

        // AFTER init is done, restore timer asynchronously (NON-BLOCKING)
        // This prevents blocking main thread during app startup
        Task {
            await MainActor.run {
                self.restoreTimerIfNeeded()

                // Send initial data to Watch after restoration
                self.sendUpdateToWatch()
            }
        }
    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        // Initialize Watch Connectivity
        _ = WatchConnectivityManager.shared

        // Listen for actions from Watch
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTakeSnusFromWatch),
            name: .takeSnusFromWatch,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUsePanicFromWatch),
            name: .usePanicFromWatch,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWatchRequestsUpdate),
            name: .watchRequestsUpdate,
            object: nil
        )

        // Send initial data immediately (synchronously)
        // This ensures Watch gets data as soon as connection is established
        sendUpdateToWatch()
    }

    @objc private func handleTakeSnusFromWatch() {
        print("⌚ Watch triggered: Take snus")
        takeSnus()
    }

    @objc private func handleUsePanicFromWatch() {
        print("⌚ Watch triggered: Use panic")
        usePanicSnus()
    }

    @objc private func handleWatchRequestsUpdate() {
        print("⌚ Watch requested update")
        sendUpdateToWatch()
    }

    private func sendUpdateToWatch() {
        WatchConnectivityManager.shared.updateContext(
            countdownTime: countdownTime,
            snusLeft: snusLeft,
            paniksnusLeft: paniksnusLeft,
            timerEndDate: timerEndDate,
            substanceName: substanceName
        )
    }

    deinit {
        // Remove all NotificationCenter observers
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .NSCalendarDayChanged, object: nil)

        // Invalidate timers
        timer?.invalidate()
        dailyCheckTimer?.invalidate()
    }

    private func restoreTimerIfNeeded() {
        let defaults = SnusManager.sharedDefaults
        let wasTimerActive = defaults.bool(forKey: UserDefaultsKeys.isTimerActive)

        // countdownTime and timerEndDate were already set in init()
        // Just need to restart the UI timer if timer is still active
        if wasTimerActive && countdownTime > 0 {
            // Timer is still running - start the countdown UI
            startCountdown()
        }

        // Clean up orphaned Live Activities asynchronously (NON-BLOCKING)
        Task {
            let hasActiveLiveActivity = !Activity<SnusTimerAttributes>.activities.isEmpty
            if hasActiveLiveActivity && !wasTimerActive {
                // Live Activity exists but timer is not active - clean up orphaned activities
                for activity in Activity<SnusTimerAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.applicationWillResignActive()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }

        // Listen for calendar day changes (midnight, timezone changes, etc.)
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
            print("Calendar day changed - checking for daily reset")
            self?.checkForDailyReset()
        }

        // Start a timer to check for daily reset every minute
        // This ensures we catch midnight even if .NSCalendarDayChanged doesn't fire
        startDailyCheckTimer()
    }

    private func startDailyCheckTimer() {
        // Invalidate existing timer if any
        dailyCheckTimer?.invalidate()

        // Check every 60 seconds if we've crossed into a new day
        dailyCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkForDailyReset()
        }
    }

    @objc func applicationWillResignActive() {
        SnusManager.sharedDefaults.set(Date(), forKey: UserDefaultsKeys.lastActiveTime)
        saveSettings()
    }

    @objc func applicationDidBecomeActive() {
        // Check for daily/weekly reset first
        checkForDailyReset()

        // Recalculate countdown time when app becomes active again
        let defaults = SnusManager.sharedDefaults
        let wasTimerActive = defaults.bool(forKey: UserDefaultsKeys.isTimerActive)

        if wasTimerActive, let timerStartTime = defaults.object(forKey: UserDefaultsKeys.timerStartTime) as? Date {
            // Recalculate remaining time based on how much time has actually passed
            let timePassed = Date().timeIntervalSince(timerStartTime)
            let remainingTime = snusInterval - timePassed

            if remainingTime > 0 {
                // Timer still running - update countdown and restart timer UI
                countdownTime = remainingTime
                // Restart timer with proper sync to whole seconds (Live Activity continues on its own)
                restartTimerUIOnly()
            } else {
                // Timer completed while app was in background - save countdownTime = 0 to UserDefaults
                countdownTime = 0
                defaults.set(0, forKey: UserDefaultsKeys.countdownTime)
                stopTimer()
            }
        }

        // Check if Live Activity was dismissed by user - do this ASYNCHRONOUSLY to avoid blocking main thread
        Task {
            let hasActiveLiveActivity = !Activity<SnusTimerAttributes>.activities.isEmpty

            if wasTimerActive && !hasActiveLiveActivity && currentActivity != nil {
                // User dismissed the Live Activity - sync state
                await MainActor.run {
                    print("Live Activity was dismissed by user - cleaning up")
                    self.currentActivity = nil
                }
            }
        }
    }

    // Restart ONLY the timer UI (not Live Activity) - used when app returns from background
    private func restartTimerUIOnly() {
        timer?.invalidate()
        isTimerRunning = true

        // Timer for UI updates only - Live Activity updates itself automatically
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Recalculate countdown from timerEndDate to prevent drift
            if let endDate = self.timerEndDate {
                let remaining = endDate.timeIntervalSinceNow
                if remaining > 0 {
                    self.countdownTime = remaining
                    // DO NOT update Live Activity every second - it updates itself!
                } else {
                    // Timer reached zero - update Live Activity with final state
                    self.countdownTime = 0
                    self.updateLiveActivity()
                    self.scheduleNotification()

                    // Save countdownTime = 0 to UserDefaults
                    SnusManager.sharedDefaults.set(0, forKey: UserDefaultsKeys.countdownTime)

                    // Delay stopping timer slightly to let Live Activity update propagate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.stopTimer()
                    }
                }
            } else {
                // Fallback - should not happen in normal operation
                if self.countdownTime > 0 {
                    self.countdownTime = max(0, self.countdownTime - 1)
                }
            }
        }
    }

    private func startCountdown() {
        guard !isTimerRunning else { return }

        timer?.invalidate()
        isTimerRunning = true

        // Start Live Activity asynchronously (NON-BLOCKING)
        // Do NOT wait for it to complete - let it happen in background
        Task {
            await self.startLiveActivityAsync()
        }

        // Timer for UI updates only - Live Activity updates itself automatically
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Recalculate countdown from timerEndDate to prevent drift
            if let endDate = self.timerEndDate {
                let remaining = endDate.timeIntervalSinceNow
                if remaining > 0 {
                    self.countdownTime = remaining
                    // DO NOT update Live Activity every second - it updates itself!
                } else {
                    // Timer reached zero - update Live Activity with final state
                    self.countdownTime = 0
                    self.updateLiveActivity()
                    self.scheduleNotification() // Play sound when timer reaches zero

                    // Save countdownTime = 0 to UserDefaults
                    SnusManager.sharedDefaults.set(0, forKey: UserDefaultsKeys.countdownTime)

                    // Delay stopping timer slightly to let Live Activity update propagate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.stopTimer()
                    }
                }
            } else {
                // Fallback - should not happen in normal operation
                if self.countdownTime > 0 {
                    self.countdownTime = max(0, self.countdownTime - 1)
                }
            }
        }
    }

    // Schedule notification to fire at exact timer end date (for background/killed app)
    private func scheduleTimerEndNotification(at endDate: Date) {
        // Check if user has enabled timer completion notifications
        let defaults = SnusManager.sharedDefaults
        let isNotificationEnabled = defaults.object(forKey: UserDefaultsKeys.isTimerNotificationEnabled) as? Bool ?? true

        guard isNotificationEnabled else {
            print("⏰ Timer completion notifications are disabled by user")
            return
        }

        // Cancel any existing timer notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_completion"])

        let timeInterval = endDate.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("⚠️ Timer end date is in the past, not scheduling notification")
            return
        }

        let content = UNMutableNotificationContent()
        let celebrationMessage = celebrationMessages().randomElement() ?? NSLocalizedString("celebration.its_time", comment: "")
        content.title = celebrationMessage
        content.body = NSLocalizedString("notification.body", comment: "")
        content.sound = .defaultCritical // Critical sound plays even when app is killed
        content.interruptionLevel = .timeSensitive

        print("🔔 Scheduling notification for \(endDate) (\(timeInterval) seconds from now)")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timer_completion", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully for timer end!")
            }
        }
    }

    private func scheduleNotification() {
        // Check if user has enabled timer completion notifications
        let defaults = SnusManager.sharedDefaults
        let isNotificationEnabled = defaults.object(forKey: UserDefaultsKeys.isTimerNotificationEnabled) as? Bool ?? true

        guard isNotificationEnabled else {
            print("⏰ Timer completion notifications are disabled by user")
            return
        }

        print("⏰ Timer reached 0 - triggering notifications and haptics")

        // ALWAYS trigger haptic and sound when timer reaches zero (foreground)
        DispatchQueue.main.async {
            print("📳 Triggering haptic feedback and sound")

            // Get selected sound from UserDefaults (default to 1315 - Anticipate)
            let defaults = SnusManager.sharedDefaults
            let soundID = defaults.object(forKey: "timerCompletionSoundID") as? UInt32 ?? 1315

            // Use system sound with vibration - respects silent mode
            // Plays sound when ringer is on, vibrates when silent
            AudioServicesPlaySystemSound(SystemSoundID(soundID))

            // Also trigger haptic feedback for extra emphasis
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }

        let content = UNMutableNotificationContent()
        // Use a random celebration message instead of static localized string
        let celebrationMessage = celebrationMessages().randomElement() ?? NSLocalizedString("celebration.its_time", comment: "")
        content.title = celebrationMessage
        content.body = NSLocalizedString("notification.body", comment: "")
        // Use critical sound to ensure it plays even when app is killed/background
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive // Makes sure notification shows up

        print("🔔 Scheduling notification with title: '\(celebrationMessage)'")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully!")
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timerEndDate = nil

        // Mark timer as inactive
        SnusManager.sharedDefaults.set(false, forKey: UserDefaultsKeys.isTimerActive)
    }

    // MARK: - Live Activity Management
    private func startLiveActivityAsync() async {
        print("🏝️ startLiveActivityAsync() called")

        // Check if user has disabled Dynamic Island in settings
        let defaults = SnusManager.sharedDefaults
        let isDynamicIslandEnabled = defaults.object(forKey: UserDefaultsKeys.isDynamicIslandEnabled) as? Bool ?? true

        print("   isDynamicIslandEnabled setting: \(isDynamicIslandEnabled)")

        guard isDynamicIslandEnabled else {
            print("   ❌ Dynamic Island is disabled by user - not starting Live Activity")
            return
        }

        let authInfo = ActivityAuthorizationInfo()
        let areActivitiesEnabled = authInfo.areActivitiesEnabled

        print("   areActivitiesEnabled: \(areActivitiesEnabled)")

        guard areActivitiesEnabled else {
            print("   ❌ Live Activities are not enabled in iOS settings - not starting Live Activity")
            return
        }

        print("   ✅ All checks passed - proceeding to create Live Activity")

        // End our tracked activity
        await endLiveActivity()

        // Also end any orphaned activities (in case of crashes/bugs)
        for activity in Activity<SnusTimerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        // Now create new activity - this must happen on background thread to avoid blocking
        let endDate = await MainActor.run { timerEndDate ?? Date().addingTimeInterval(countdownTime) }
        let startTime = await MainActor.run { endDate.addingTimeInterval(-snusInterval) }
        let currentSnusLeft = await MainActor.run { snusLeft }
        let currentCountdownTime = await MainActor.run { countdownTime }
        let currentSnusInterval = await MainActor.run { snusInterval }
        let currentSubstanceName = await MainActor.run { localizedSubstanceName }

        let attributes = SnusTimerAttributes(
            startTime: startTime,
            totalTime: currentSnusInterval
        )

        // Pick a random celebration message if timer is done
        let message = currentCountdownTime == 0 ? celebrationMessages().randomElement() : nil

        let initialState = SnusTimerAttributes.ContentState(
            endDate: endDate,
            isReady: currentCountdownTime == 0,
            snusLeft: currentSnusLeft,
            totalTime: currentSnusInterval,
            celebrationMessage: message,
            substanceName: currentSubstanceName,
            waitingMessage: encouragementMessages().randomElement(),
            leftLabel: NSLocalizedString("main.remaining", comment: "")
        )

        do {
            // Set staleDate to endDate so widget updates when timer completes
            let staleDate = currentCountdownTime > 0 ? endDate : nil

            let activity = try Activity<SnusTimerAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: staleDate),
                pushType: nil
            )

            // Update currentActivity on main thread
            await MainActor.run {
                self.currentActivity = activity
            }

            print("Live Activity started successfully with endDate: \(endDate), staleDate: \(String(describing: staleDate))")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity else { return }

        // Calculate end date - if timer is done, use FAR past time to prevent counting upwards
        let endDate: Date
        if countdownTime == 0 {
            // Timer is done - set endDate to FAR in the past (1 year) to ensure .timer style never counts upward
            endDate = Date().addingTimeInterval(-365 * 24 * 3600)
        } else {
            // Timer is running - use stored end date to avoid time drift
            endDate = timerEndDate ?? Date().addingTimeInterval(countdownTime)
        }

        // Pick a random celebration message if timer is done
        let message = countdownTime == 0 ? celebrationMessages().randomElement() : nil

        let updatedState = SnusTimerAttributes.ContentState(
            endDate: endDate,
            isReady: countdownTime == 0,
            snusLeft: snusLeft,
            totalTime: snusInterval,
            celebrationMessage: message,
            substanceName: localizedSubstanceName,
            waitingMessage: encouragementMessages().randomElement(),
            leftLabel: NSLocalizedString("main.remaining", comment: "")
        )

        Task {
            // Set staleDate to endDate so widget updates when timer completes
            let staleDate = countdownTime > 0 ? endDate : nil

            await activity.update(
                .init(state: updatedState, staleDate: staleDate)
            )
        }
    }

    private func endLiveActivity() async {
        guard let activity = currentActivity else { return }

        let finalState = SnusTimerAttributes.ContentState(
            endDate: Date().addingTimeInterval(-365 * 24 * 3600),  // 1 year in the past to prevent counting upward
            isReady: true,
            snusLeft: snusLeft,
            totalTime: snusInterval,
            celebrationMessage: celebrationMessages().randomElement(),
            substanceName: localizedSubstanceName,
            waitingMessage: nil,
            leftLabel: NSLocalizedString("main.remaining", comment: "")
        )

        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        currentActivity = nil
    }

    // Public method to end Live Activity from UI
    func endLiveActivityPublic() async {
        await endLiveActivity()
    }

    // Public method to restart timer with new interval (for settings changes)
    func restartTimerWithNewInterval() {
        guard SnusManager.sharedDefaults.bool(forKey: UserDefaultsKeys.isTimerActive) else {
            // Timer not active, nothing to restart
            return
        }

        // Stop current timer
        timer?.invalidate()
        timer = nil
        isTimerRunning = false

        // Update timerEndDate based on new countdown
        timerEndDate = Date().addingTimeInterval(countdownTime)

        // Restart timer with new values
        startCountdown()
    }

    func takeSnus() {
        guard snusLeft > 0 else { return }

        snusLeft -= 1

        // Stop timer first
        stopTimer()

        // Reset countdown to exact interval time
        countdownTime = snusInterval

        // Calculate and store end date
        timerEndDate = Date().addingTimeInterval(snusInterval)

        // Schedule notification to fire at exact timer end time
        scheduleTimerEndNotification(at: timerEndDate!)

        // Save start time for background persistence
        SnusManager.sharedDefaults.set(Date(), forKey: UserDefaultsKeys.timerStartTime)
        SnusManager.sharedDefaults.set(true, forKey: UserDefaultsKeys.isTimerActive)
        SnusManager.sharedDefaults.set(Date(), forKey: UserDefaultsKeys.lastSnusTime)

        saveSettings()

        // Start countdown immediately
        startCountdown()

        // Send update to Watch
        sendUpdateToWatch()
    }

    func usePanicSnus() {
        guard paniksnusLeft > 0 else { return }

        // Only decrease panic snus count, don't touch the timer
        paniksnusLeft -= 1
        saveSettings()

        // Send update to Watch
        sendUpdateToWatch()
    }

    func saveSettings() {
        let defaults = SnusManager.sharedDefaults

        // If this is first time configuring, save daily goal
        let hasConfigured = defaults.bool(forKey: UserDefaultsKeys.hasConfiguredSettings)
        if !hasConfigured {
            // First time setup - save the daily goal so resetDailyValues() knows what to reset to
            // NOTE: snusLeft and paniksnusLeft are set explicitly in NjutningsInställningarView, not here!
            defaults.set(snusLeft, forKey: UserDefaultsKeys.dailyGoal)
        }

        defaults.set(snusLeft, forKey: UserDefaultsKeys.snusLeft)
        defaults.set(paniksnusLeft, forKey: UserDefaultsKeys.paniksnusLeft)
        defaults.set(paniksnus, forKey: UserDefaultsKeys.paniksnus)
        defaults.set(snusInterval, forKey: UserDefaultsKeys.snusInterval)
        defaults.set(countdownTime, forKey: UserDefaultsKeys.countdownTime)
        defaults.set(substanceName, forKey: UserDefaultsKeys.selectedSubstance)  // Save substance name
        defaults.set(true, forKey: UserDefaultsKeys.hasConfiguredSettings)
        defaults.set(true, forKey: UserDefaultsKeys.hasBeenInitialized)  // CRITICAL: Always set this to ensure init() reads from UserDefaults
    }

    func resetCountdown() {
        stopTimer()
        countdownTime = snusInterval
        timerEndDate = nil
    }

    func stopAndResetTimer() {
        // Stop the timer completely
        stopTimer()

        // End Live Activity
        Task {
            await endLiveActivity()
        }

        // Reset countdown
        countdownTime = snusInterval

        // Clear all timer-related flags
        SnusManager.sharedDefaults.set(false, forKey: UserDefaultsKeys.isTimerActive)
        SnusManager.sharedDefaults.removeObject(forKey: UserDefaultsKeys.timerStartTime)
    }

    func checkForDailyReset() {
        let defaults = SnusManager.sharedDefaults
        let calendar = Calendar.current
        let now = Date()

        // Check for daily reset
        if let lastResetDate = defaults.object(forKey: UserDefaultsKeys.lastResetDate) as? Date {
            // Check if it's a new day
            if !calendar.isDate(lastResetDate, inSameDayAs: now) {
                resetDailyValues()
                defaults.set(now, forKey: UserDefaultsKeys.lastResetDate)
            }
        } else {
            // First time running app, set today as last reset date
            defaults.set(now, forKey: UserDefaultsKeys.lastResetDate)
        }

        // Check for weekly reset (panic snus) - Reset every Monday at 00:00
        if let lastWeekResetDate = defaults.object(forKey: UserDefaultsKeys.lastWeekResetDate) as? Date {
            // Get the weekday for both dates (1 = Sunday, 2 = Monday, etc.)
            let lastWeekday = calendar.component(.weekday, from: lastWeekResetDate)
            let currentWeekday = calendar.component(.weekday, from: now)

            // Check if we've crossed a Monday since last reset
            // This handles both: 1) different weeks AND 2) crossing from Sunday to Monday
            let hasCrossedMonday: Bool
            if calendar.isDate(lastWeekResetDate, equalTo: now, toGranularity: .weekOfYear) {
                // Same week - check if we crossed from Sunday (1) to Monday (2)
                hasCrossedMonday = lastWeekday == 1 && currentWeekday == 2
            } else {
                // Different week - we've definitely crossed a Monday
                hasCrossedMonday = true
            }

            if hasCrossedMonday {
                resetWeeklyValues()
                defaults.set(now, forKey: UserDefaultsKeys.lastWeekResetDate)
            }
        } else {
            // First time running app, set this week as last reset week
            defaults.set(now, forKey: UserDefaultsKeys.lastWeekResetDate)
        }
    }

    private func resetDailyValues() {
        print("🌅 Resetting daily values - New day detected!")

        let defaults = SnusManager.sharedDefaults
        let wasTimerActive = defaults.bool(forKey: UserDefaultsKeys.isTimerActive)

        // Check if timer is currently active and should continue running
        if wasTimerActive, let timerStartTime = defaults.object(forKey: UserDefaultsKeys.timerStartTime) as? Date {
            // Timer is active - check if it should still be running
            let timePassed = Date().timeIntervalSince(timerStartTime)
            let remainingTime = snusInterval - timePassed

            if remainingTime > 0 {
                // Timer should continue running - only reset snusLeft, keep timer going
                print("⏱️ Timer is still active - preserving countdown")
                let dailyGoal = defaults.integer(forKey: UserDefaultsKeys.dailyGoal)
                snusLeft = dailyGoal > 0 ? dailyGoal : 10  // Fallback to 10 if not set

                // Update Live Activity with new snusLeft count
                updateLiveActivity()

                saveSettings()
                print("✅ Daily reset complete (timer preserved) - snusLeft: \(snusLeft), countdownTime: \(countdownTime)")
                return
            }
        }

        // Timer not active or has completed - do full reset
        print("🛑 No active timer - performing full reset")

        // Stop any running timer and Live Activity completely
        stopTimer()

        Task {
            await endLiveActivity()
        }

        // Reset to user's configured daily goal (NOT panic snus - that's weekly)
        let dailyGoal = defaults.integer(forKey: UserDefaultsKeys.dailyGoal)
        snusLeft = dailyGoal > 0 ? dailyGoal : 10  // Fallback to 10 if not set
        countdownTime = snusInterval

        // Clear timer state
        SnusManager.sharedDefaults.set(false, forKey: UserDefaultsKeys.hasStartedTimerToday)
        SnusManager.sharedDefaults.set(false, forKey: UserDefaultsKeys.isTimerActive)
        SnusManager.sharedDefaults.removeObject(forKey: UserDefaultsKeys.timerStartTime)

        saveSettings()

        print("✅ Daily reset complete - snusLeft: \(snusLeft), countdownTime: \(countdownTime)")
    }

    // MARK: - Auto-Progression

    /// Returns the current week number in the progression (1-based), or nil if not active
    var progressionCurrentWeek: Int? {
        let defaults = SnusManager.sharedDefaults
        guard isProgressionEnabled,
              let startDate = defaults.object(forKey: UserDefaultsKeys.progressionStartDate) as? Date else {
            return nil
        }
        let totalWeeks = max(1, defaults.integer(forKey: UserDefaultsKeys.progressionWeeks))
        let weeksPassed = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
        return min(weeksPassed + 1, totalWeeks)
    }

    /// Returns the configured target interval in seconds
    var progressionTargetIntervalValue: TimeInterval {
        return SnusManager.sharedDefaults.double(forKey: UserDefaultsKeys.progressionTargetInterval)
    }

    /// Returns the total number of progression weeks
    var progressionTotalWeeks: Int {
        return max(1, SnusManager.sharedDefaults.integer(forKey: UserDefaultsKeys.progressionWeeks))
    }

    /// Returns the target interval for the current progression week
    var progressionCurrentTargetInterval: TimeInterval? {
        let defaults = SnusManager.sharedDefaults
        guard isProgressionEnabled,
              let startDate = defaults.object(forKey: UserDefaultsKeys.progressionStartDate) as? Date else {
            return nil
        }
        let startInterval = defaults.double(forKey: UserDefaultsKeys.progressionStartInterval)
        let targetInterval = defaults.double(forKey: UserDefaultsKeys.progressionTargetInterval)
        let totalWeeks = max(1, defaults.integer(forKey: UserDefaultsKeys.progressionWeeks))

        guard startInterval > 0, targetInterval > startInterval, totalWeeks > 0 else { return nil }

        let weeksPassed = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
        let currentWeek = min(weeksPassed, totalWeeks - 1)  // 0-based, clamped

        // Linear interpolation between start and target
        let stepPerWeek = (targetInterval - startInterval) / Double(totalWeeks - 1 > 0 ? totalWeeks - 1 : 1)
        let calculatedInterval = startInterval + (stepPerWeek * Double(currentWeek))

        // Round to nearest 15 minutes (900 seconds)
        return (calculatedInterval / 900).rounded() * 900
    }

    /// Start a new progression plan
    func startProgression(startInterval: TimeInterval, targetInterval: TimeInterval, weeks: Int) {
        let defaults = SnusManager.sharedDefaults
        defaults.set(true, forKey: UserDefaultsKeys.isProgressionEnabled)
        defaults.set(startInterval, forKey: UserDefaultsKeys.progressionStartInterval)
        defaults.set(targetInterval, forKey: UserDefaultsKeys.progressionTargetInterval)
        defaults.set(weeks, forKey: UserDefaultsKeys.progressionWeeks)
        defaults.set(Date(), forKey: UserDefaultsKeys.progressionStartDate)
        isProgressionEnabled = true

        // Set the starting interval
        snusInterval = startInterval
        saveSettings()
    }

    /// Stop the progression plan
    func stopProgression() {
        let defaults = SnusManager.sharedDefaults
        defaults.set(false, forKey: UserDefaultsKeys.isProgressionEnabled)
        isProgressionEnabled = false
    }

    /// Apply progression interval for the current week (called during weekly reset)
    private func applyProgressionIfNeeded() {
        guard isProgressionEnabled, let targetInterval = progressionCurrentTargetInterval else { return }

        let oldInterval = snusInterval
        snusInterval = targetInterval
        saveSettings()

        print("📈 Auto-progression: interval changed from \(Int(oldInterval/60))min to \(Int(targetInterval/60))min")

        // Check if progression is complete
        if let currentWeek = progressionCurrentWeek, currentWeek >= progressionTotalWeeks {
            print("🎉 Auto-progression complete! Target reached.")
            // Keep the final interval but disable further progression
            stopProgression()
        }
    }

    private func resetWeeklyValues() {
        print("📅 Resetting weekly values - New week detected!")

        // Reset panic snus for the new week
        paniksnusLeft = paniksnus > 0 ? paniksnus : 5

        // Apply auto-progression interval increase
        applyProgressionIfNeeded()

        saveSettings()

        print("✅ Weekly reset complete - paniksnusLeft: \(paniksnusLeft)")
    }
}

// MARK: - Watch Connectivity Manager

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendTimerUpdate(countdownTime: TimeInterval, snusLeft: Int, paniksnusLeft: Int, isReady: Bool, substanceName: String) {
        guard WCSession.default.isReachable else { return }
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
    }

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
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "takeSnus":
                    NotificationCenter.default.post(name: .takeSnusFromWatch, object: nil)
                    replyHandler(["status": "success"])
                case "usePanic":
                    NotificationCenter.default.post(name: .usePanicFromWatch, object: nil)
                    replyHandler(["status": "success"])
                case "requestUpdate":
                    NotificationCenter.default.post(name: .watchRequestsUpdate, object: nil)
                    replyHandler(["status": "updating"])
                default:
                    replyHandler(["status": "unknown_action"])
                }
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {}
}
