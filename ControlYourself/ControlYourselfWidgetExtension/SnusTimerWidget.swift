import ActivityKit
import WidgetKit
import SwiftUI

struct SnusTimerWidget: Widget {
    // Calculate live progress from endDate
    private func calculateProgress(context: ActivityViewContext<SnusTimerAttributes>) -> Double {
        if context.state.isReady {
            return 1.0
        }

        let totalTime = context.attributes.totalTime
        let timeRemaining = max(0, context.state.endDate.timeIntervalSinceNow)

        if totalTime > 0 {
            return max(0, min(1, (totalTime - timeRemaining) / totalTime))
        }
        return 0.0
    }

    // Color based on progress: red -> yellow -> green
    private func progressColor(for progress: Double, isReady: Bool) -> Color {
        if isReady {
            return .green
        }

        // Progress 0.0 (just started) -> Red
        // Progress 0.5 (halfway) -> Yellow
        // Progress 1.0 (done) -> Green
        if progress < 0.5 {
            // Red to Yellow (0% - 50%)
            let localProgress = progress / 0.5
            let red = 1.0
            let green = localProgress // 0.0 -> 1.0
            return Color(red: red, green: green, blue: 0.0)
        } else {
            // Yellow to Green (50% - 100%)
            let localProgress = (progress - 0.5) / 0.5
            let red = 1.0 - localProgress // 1.0 -> 0.0
            let green = 1.0
            return Color(red: red, green: green, blue: 0.0)
        }
    }

    private func progressGradient(for progress: Double, isReady: Bool) -> LinearGradient {
        if isReady {
            return LinearGradient(
                colors: [.green, .mint],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        if progress < 0.5 {
            // Red to Yellow gradient (0% - 50%)
            let localProgress = progress / 0.5
            let startColor = Color(red: 1.0, green: localProgress * 0.9, blue: 0.0)
            let endColor = Color(red: 1.0, green: localProgress * 1.0, blue: 0.0)
            return LinearGradient(
                colors: [startColor, endColor],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            // Yellow to Green gradient (50% - 100%)
            let localProgress = (progress - 0.5) / 0.5
            let startRed = 1.0 - (localProgress * 0.5)
            let endRed = 1.0 - localProgress
            return LinearGradient(
                colors: [Color(red: startRed, green: 1.0, blue: 0.0), Color(red: endRed, green: 1.0, blue: 0.0)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnusTimerAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // ULTRA minimal - basically nothing
                DynamicIslandExpandedRegion(.leading) {
                    Spacer()
                        .frame(width: 1, height: 1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Spacer()
                        .frame(width: 1, height: 1)
                }
                DynamicIslandExpandedRegion(.center) {
                    // Minimal center content
                    let liveProgress = calculateProgress(context: context)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(progressColor(for: liveProgress, isReady: context.state.isReady))
                            .frame(width: 8, height: 8)

                        if context.state.isReady {
                            // Timer is complete - show celebration message
                            Text(context.state.celebrationMessage ?? "Dags! 🎉")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.green)
                        } else {
                            // Calculate time remaining to decide what to show
                            let timeRemaining = context.state.endDate.timeIntervalSinceNow

                            if timeRemaining <= 1 {
                                // Last second or already passed - show static celebration
                                Text(context.state.celebrationMessage ?? "Dags! 🎉")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.green)
                            } else {
                                // Timer still has time - use .timer for live updates
                                Text(context.state.endDate, style: .timer)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            } compactLeading: {
                // Compact leading - colored circle with LIVE progress
                let liveProgress = calculateProgress(context: context)
                Circle()
                    .fill(progressColor(for: liveProgress, isReady: context.state.isReady))
                    .frame(width: 12, height: 12)
            } compactTrailing: {
                // Compact trailing - timer or short message
                if context.state.isReady {
                    // Timer is complete - show celebration message
                    Text(context.state.celebrationMessage ?? "Dags! 🎉")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                } else {
                    // Calculate time remaining to decide what to show
                    let timeRemaining = context.state.endDate.timeIntervalSinceNow

                    if timeRemaining <= 1 {
                        // Last second or already passed - show static celebration
                        Text(context.state.celebrationMessage ?? "Dags! 🎉")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    } else {
                        // Timer still has time - use .timer for live updates
                        Text(context.state.endDate, style: .timer)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                }
            } minimal: {
                // Minimal - LIVE progress
                let liveProgress = calculateProgress(context: context)
                Circle()
                    .fill(progressColor(for: liveProgress, isReady: context.state.isReady))
                    .frame(width: 10, height: 10)
            }
        }
    }

    private func timeStatus(for progress: Double) -> String {
        if progress < 0.4 {
            return "Väntar"
        } else if progress < 0.75 {
            return "Snart!"
        } else {
            return "Nästan!"
        }
    }

    private func motivationalMessage(for progress: Double) -> String {
        let messages = [
            "Dags! 🎉",
            "Nu! ✨",
            "Ta en! 💪",
            "Redo! 🔥",
            "Njut! 😊"
        ]
        // Use progress as seed to rotate messages
        let index = Int(progress * 100) % messages.count
        return messages[index]
    }

    private func shortMessage() -> String {
        let messages = [
            "Dags!",
            "Nu!",
            "Redo!",
            "Kör!"
        ]
        // Random short message
        return messages[Int.random(in: 0..<messages.count)]
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func compactTimeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60

        if hours > 0 {
            return String(format: "%dh%dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "0m"
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<SnusTimerAttributes>

    // Calculate live progress
    private func calculateProgress() -> Double {
        if context.state.isReady {
            return 1.0
        }

        let totalTime = context.attributes.totalTime
        let timeRemaining = max(0, context.state.endDate.timeIntervalSinceNow)

        if totalTime > 0 {
            return max(0, min(1, (totalTime - timeRemaining) / totalTime))
        }
        return 0.0
    }

    // Get substance name for display (already localized from SnusManager)
    private func displaySubstanceName() -> String {
        return context.state.substanceName
    }

    private func progressColor(for progress: Double, isReady: Bool) -> Color {
        if isReady {
            return .green
        }

        // Same as main widget: red -> yellow -> green
        if progress < 0.5 {
            let localProgress = progress / 0.5
            return Color(red: 1.0, green: localProgress, blue: 0.0)
        } else {
            let localProgress = (progress - 0.5) / 0.5
            return Color(red: 1.0 - localProgress, green: 1.0, blue: 0.0)
        }
    }

    private func progressGradient(for progress: Double, isReady: Bool) -> LinearGradient {
        if isReady {
            return LinearGradient(
                colors: [.green, .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        if progress < 0.5 {
            let localProgress = progress / 0.5
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: localProgress * 0.9, blue: 0.0),
                    Color(red: 1.0, green: localProgress * 1.0, blue: 0.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            let localProgress = (progress - 0.5) / 0.5
            return LinearGradient(
                colors: [
                    Color(red: 1.0 - (localProgress * 0.5), green: 1.0, blue: 0.0),
                    Color(red: 1.0 - localProgress, green: 1.0, blue: 0.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        let liveProgress = calculateProgress()

        HStack(spacing: 16) {
            // Icon with dynamic color
            ZStack {
                Circle()
                    .fill(progressGradient(for: liveProgress, isReady: context.state.isReady))
                    .frame(width: 44, height: 44)

                Image(systemName: context.state.isReady ? "checkmark.circle.fill" : "timer")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                if context.state.isReady {
                    // Timer is complete - show celebration
                    Text(context.state.celebrationMessage ?? "Dags för en \(displaySubstanceName())! ✨")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                } else if context.state.endDate.timeIntervalSinceNow <= 0 {
                    // Timer has reached 0
                    Text(context.state.celebrationMessage ?? "Dags för en \(displaySubstanceName())! ✨")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                } else {
                    Text(waitingMessage())
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }

                // Calculate time remaining to decide what to show
                let timeRemaining = context.state.endDate.timeIntervalSinceNow

                if context.state.isReady || timeRemaining <= 1 {
                    // Timer is done or in last second - show 00:00:00
                    Text("00:00:00")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                } else {
                    // Timer still has time - use .timer for live updates
                    Text(context.state.endDate, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
            }

            Spacer()

            // Snus left badge
            VStack(spacing: 2) {
                Text("\(context.state.snusLeft)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("kvar")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.3))
        .activitySystemActionForegroundColor(.white)
    }

    // Get rotating waiting message based on progress
    private func waitingMessage() -> String {
        let progress = calculateProgress()
        let messages = [
            "Håll ut! 💪",
            "Snart där! ✨",
            "Du klarar det! 🌟",
            "Fortsätt så! 🔥",
            "Stark! 💎",
            "Nästan! 🚀",
            "Bra jobbat! ⭐",
            "Håll i! 🐻"
        ]
        // Use progress as seed to rotate messages deterministically
        let index = Int(progress * 100) % messages.count
        return messages[index]
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
