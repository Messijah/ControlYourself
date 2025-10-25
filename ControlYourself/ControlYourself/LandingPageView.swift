//
//  LandingPageView.swift
//  ControlYourself
//
//  Created by Jens on 2024-03-29.
//


import SwiftUI
import AudioToolbox

// MARK: - iPad Layout Helper
fileprivate var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

// MARK: - App Theme
enum AppTheme: String, CaseIterable, Identifiable {
    case purpleDream = "purple_dream"
    case oceanBlue = "ocean_blue"
    case sunsetOrange = "sunset_orange"
    case forestGreen = "forest_green"

    var id: String { rawValue }

    var localizedName: String {
        NSLocalizedString("theme.\(rawValue)", comment: "")
    }

    // Primary gradient colors (used for timer circle when ready)
    var primaryColors: [Color] {
        switch self {
        case .purpleDream:
            return [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)]
        case .oceanBlue:
            return [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.0, green: 0.8, blue: 1.0)]
        case .sunsetOrange:
            return [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.5)]
        case .forestGreen:
            return [Color(red: 0.2, green: 0.8, blue: 0.5), Color(red: 0.3, green: 0.9, blue: 0.4)]
        }
    }

    // Secondary gradient colors (used for timer circle when counting down)
    var secondaryColors: [Color] {
        switch self {
        case .purpleDream:
            return [Color(red: 0.5, green: 0.3, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.9)]
        case .oceanBlue:
            return [Color(red: 0.1, green: 0.4, blue: 0.7), Color(red: 0.0, green: 0.6, blue: 0.8)]
        case .sunsetOrange:
            return [Color(red: 0.8, green: 0.4, blue: 0.1), Color(red: 0.9, green: 0.2, blue: 0.4)]
        case .forestGreen:
            return [Color(red: 0.1, green: 0.6, blue: 0.3), Color(red: 0.2, green: 0.7, blue: 0.3)]
        }
    }

    // Progress bar gradient colors
    var progressGradient: [Color] {
        switch self {
        case .purpleDream:
            return [Color(red: 0.7, green: 0.5, blue: 1.0), Color(red: 0.5, green: 0.7, blue: 1.0)]
        case .oceanBlue:
            return [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.1, green: 0.9, blue: 1.0)]
        case .sunsetOrange:
            return [Color(red: 1.0, green: 0.7, blue: 0.3), Color(red: 1.0, green: 0.4, blue: 0.6)]
        case .forestGreen:
            return [Color(red: 0.3, green: 0.9, blue: 0.6), Color(red: 0.4, green: 1.0, blue: 0.5)]
        }
    }

    // Icon/accent gradient colors (used for buttons and icons)
    var accentGradient: [Color] {
        switch self {
        case .purpleDream:
            return [.purple, .blue]
        case .oceanBlue:
            return [.blue, .cyan]
        case .sunsetOrange:
            return [.orange, .pink]
        case .forestGreen:
            return [.green, .mint]
        }
    }

    // Shadow color for ready state
    var readyShadowColor: Color {
        switch self {
        case .purpleDream:
            return .green
        case .oceanBlue:
            return .cyan
        case .sunsetOrange:
            return .orange
        case .forestGreen:
            return .mint
        }
    }

    // Shadow color for countdown state
    var countdownShadowColor: Color {
        switch self {
        case .purpleDream:
            return .purple
        case .oceanBlue:
            return .blue
        case .sunsetOrange:
            return .orange
        case .forestGreen:
            return .green
        }
    }

    // Secondary shadow color for ready state
    var readySecondaryShadowColor: Color {
        switch self {
        case .purpleDream:
            return .mint
        case .oceanBlue:
            return Color(red: 0.0, green: 0.9, blue: 1.0)
        case .sunsetOrange:
            return .pink
        case .forestGreen:
            return .green
        }
    }

    // Secondary shadow color for countdown state
    var countdownSecondaryShadowColor: Color {
        switch self {
        case .purpleDream:
            return .blue
        case .oceanBlue:
            return .cyan
        case .sunsetOrange:
            return .red
        case .forestGreen:
            return .mint
        }
    }

    // Background gradient for cards
    var cardBackgroundGradient: (isReady: Bool) -> [Color] {
        return { isReady in
            if isReady {
                switch self {
                case .purpleDream:
                    return [Color.green.opacity(0.15), Color.mint.opacity(0.1)]
                case .oceanBlue:
                    return [Color.cyan.opacity(0.15), Color.blue.opacity(0.1)]
                case .sunsetOrange:
                    return [Color.orange.opacity(0.15), Color.pink.opacity(0.1)]
                case .forestGreen:
                    return [Color.mint.opacity(0.15), Color.green.opacity(0.1)]
                }
            } else {
                switch self {
                case .purpleDream:
                    return [Color.purple.opacity(0.15), Color.blue.opacity(0.1)]
                case .oceanBlue:
                    return [Color.blue.opacity(0.15), Color.cyan.opacity(0.1)]
                case .sunsetOrange:
                    return [Color.orange.opacity(0.15), Color.red.opacity(0.1)]
                case .forestGreen:
                    return [Color.green.opacity(0.15), Color.mint.opacity(0.1)]
                }
            }
        }
    }

    // Button gradient for main action button
    var buttonGradient: (isReady: Bool) -> [Color] {
        return { isReady in
            if isReady {
                switch self {
                case .purpleDream:
                    return [Color.green, Color.mint]
                case .oceanBlue:
                    return [Color.cyan, Color.blue]
                case .sunsetOrange:
                    return [Color.orange, Color.pink]
                case .forestGreen:
                    return [Color.mint, Color.green]
                }
            } else {
                switch self {
                case .purpleDream:
                    return [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]
                case .oceanBlue:
                    return [Color.blue.opacity(0.6), Color.cyan.opacity(0.6)]
                case .sunsetOrange:
                    return [Color.orange.opacity(0.6), Color.red.opacity(0.6)]
                case .forestGreen:
                    return [Color.green.opacity(0.6), Color.mint.opacity(0.6)]
                }
            }
        }
    }

    // Get the button shadow color
    var buttonShadowColor: (isReady: Bool) -> Color {
        return { isReady in
            if isReady {
                return self.readyShadowColor
            } else {
                return self.countdownShadowColor
            }
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.purpleDream.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .purpleDream
    }
}

// MARK: - Timer Completion Sounds
struct TimerSound: Identifiable, Hashable {
    let id: UInt32
    let name: String
    let localizedKey: String

    var localizedName: String {
        NSLocalizedString(localizedKey, comment: "")
    }
}

private let availableTimerSounds: [TimerSound] = [
    TimerSound(id: 1315, name: "Anticipate", localizedKey: "sound.anticipate"),
    TimerSound(id: 1013, name: "Bell", localizedKey: "sound.bell"),
    TimerSound(id: 1005, name: "Chime", localizedKey: "sound.chime"),
    TimerSound(id: 1057, name: "Ding", localizedKey: "sound.ding"),
    TimerSound(id: 1052, name: "Fanfare", localizedKey: "sound.fanfare"),
    TimerSound(id: 1328, name: "Jingle", localizedKey: "sound.jingle"),
    TimerSound(id: 1016, name: "Ping", localizedKey: "sound.ping"),
    TimerSound(id: 1000, name: "Tri-tone", localizedKey: "sound.tritone")
]

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let timerDisplayFormat = "timerDisplayFormat"
    static let isDynamicIslandEnabled = "isDynamicIslandEnabled"
    static let isTimerNotificationEnabled = "isTimerNotificationEnabled"
    static let timerCompletionSoundID = "timerCompletionSoundID"
}

struct LandingPageView: View {
    @ObservedObject var snusManager: SnusManager
    @ObservedObject var statisticsManager: StatisticsManager
    @StateObject private var themeManager = ThemeManager.shared
    var onRestartApp: () -> Void
    @State private var showingSettings = false
    @State private var showingStatistics = false
    @State private var encouragementIndex: Int = 0
    @State private var showEarlyWarning = false
    @State private var isCelebrating = false
    @State private var celebrationScale: CGFloat = 1.0
    @State private var currentTime = Date()
    @State private var snusLeftScale: CGFloat = 1.0
    @State private var panicLeftScale: CGFloat = 1.0
    @State private var timerDisplayFormat: String = "HH:MM"

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private let encouragementMessages = [
        NSLocalizedString("encouragement.you_can_do_it", comment: ""),
        NSLocalizedString("encouragement.hold_on", comment: ""),
        NSLocalizedString("encouragement.good_job", comment: ""),
        NSLocalizedString("encouragement.keep_going", comment: ""),
        NSLocalizedString("encouragement.you_are_strong", comment: "")
    ]

    private let celebrationMessages = [
        NSLocalizedString("celebration.perfect_timing", comment: ""),
        NSLocalizedString("celebration.well_done", comment: ""),
        NSLocalizedString("celebration.you_can_take_one", comment: ""),
        NSLocalizedString("celebration.time_is_up", comment: "")
    ]

    private let morningMessages = [
        NSLocalizedString("morning.lets_go", comment: ""),
        NSLocalizedString("morning.new_day", comment: ""),
        NSLocalizedString("morning.welcome_back", comment: ""),
        NSLocalizedString("morning.ready", comment: ""),
        NSLocalizedString("morning.here_we_go", comment: "")
    ]

    var progress: Double {
        guard snusManager.snusInterval > 0 else { return 0 }
        return 1.0 - (snusManager.countdownTime / snusManager.snusInterval)
    }

    var isReady: Bool {
        return snusManager.countdownTime == 0
    }

    var isFirstOfDay: Bool {
        // Check if no timer has been started today
        let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        let hasStartedToday = defaults.bool(forKey: "hasStartedTimerToday")

        // Only true if we haven't started the timer today at all
        // Don't check countdownTime - just rely on the flag
        return !hasStartedToday
    }

    // Dynamic gradient that changes smoothly based on progress
    // Uses theme colors when ready, otherwise shows progress from secondary to primary
    func progressGradient(for progress: Double, isReady: Bool) -> LinearGradient {
        let theme = themeManager.currentTheme

        if isReady {
            return LinearGradient(
                colors: theme.primaryColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        if progress < 0.5 {
            // Red to Yellow gradient (0% - 50%)
            let localProgress = progress / 0.5
            let startColor = Color(red: 1.0, green: localProgress * 0.9, blue: 0.0)
            let endColor = Color(red: 1.0, green: localProgress * 1.0, blue: 0.0)
            return LinearGradient(
                colors: [startColor, endColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Yellow to theme's ready color gradient (50% - 100%)
            let localProgress = (progress - 0.5) / 0.5
            let startRed = 1.0 - (localProgress * 0.5)
            let endRed = 1.0 - localProgress
            return LinearGradient(
                colors: [Color(red: startRed, green: 1.0, blue: 0.0), Color(red: endRed, green: 1.0, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var currentGradient: LinearGradient {
        return progressGradient(for: progress, isReady: isReady)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern mesh gradient background
                MeshGradientBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                // Top Stats Bar with glassmorphism
                HStack(spacing: 16) {
                    ModernStatCard(
                        icon: "circle.hexagongrid.fill",
                        value: "\(snusManager.snusLeft)",
                        label: NSLocalizedString("main.remaining", comment: ""),
                        gradient: LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        scale: snusLeftScale
                    )

                    Spacer()

                    ModernStatCard(
                        icon: "bolt.shield.fill",
                        value: "\(snusManager.paniksnusLeft)",
                        label: NSLocalizedString("main.panic", comment: ""),
                        gradient: LinearGradient(
                            colors: snusManager.paniksnusLeft > 0 ? [.red, .orange] : [.gray, .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        scale: panicLeftScale
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Modern Progress Ring with depth
                ZStack {
                    // Outer glow ring - enhanced glow effect
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: themeManager.currentTheme.cardBackgroundGradient(isReady: isReady),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 32
                        )
                        .frame(width: 330, height: 330)
                        .blur(radius: 25)

                    // Celebration ring when ready
                    if isReady {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: themeManager.currentTheme.primaryColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 20
                            )
                            .frame(width: 320, height: 320)
                            .scaleEffect(celebrationScale)
                            .opacity(2.0 - celebrationScale)
                            .blur(radius: 8)
                    }

                    // Main progress ring with enhanced visual depth
                    ZStack {
                        // Background ring
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 18)
                            .frame(width: 300, height: 300)

                        CircularProgressView(
                            progress: progress,
                            lineWidth: 18,
                            gradient: currentGradient
                        )
                        .frame(width: 300, height: 300)

                        // Inner shadow for depth
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            .frame(width: 283, height: 283)
                    }
                    .shadow(
                        color: (isReady ? themeManager.currentTheme.readyShadowColor : themeManager.currentTheme.countdownShadowColor).opacity(0.5),
                        radius: isReady ? 45 : 30,
                        x: 0,
                        y: 15
                    )
                    .shadow(
                        color: (isReady ? themeManager.currentTheme.readySecondaryShadowColor : themeManager.currentTheme.countdownSecondaryShadowColor).opacity(0.4),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                    // Content inside ring
                    VStack(spacing: 16) {
                        if isReady && !isFirstOfDay {
                            // Celebration icon with gradient
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: themeManager.currentTheme.primaryColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .blur(radius: 20)
                                    .scaleEffect(isCelebrating ? 1.3 : 1.0)

                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 54, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .mint.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .scaleEffect(isCelebrating ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: isCelebrating)
                            }
                        } else if isFirstOfDay {
                            // Morning icon with glow
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .yellow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .blur(radius: 20)

                                Image(systemName: "sun.horizon.fill")
                                    .font(.system(size: 54, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .orange.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }

                        // Timer text with enhanced gradient and glow
                        // Use .timer style for live countdown (works when app is killed), static text when done
                        Group {
                            if !isReady && !isFirstOfDay {
                                // Timer is active - show HH:MM format without seconds
                                Text(timeString(from: snusManager.countdownTime))
                                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.95)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .monospacedDigit()
                                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            } else {
                                // Timer is done or first of day - use static text
                                Text(timeString(from: snusManager.countdownTime))
                                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .mint, .green.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .monospacedDigit()
                                    .scaleEffect(isCelebrating ? 1.08 : 1.0)
                                    .shadow(color: Color.green.opacity(0.3), radius: 12, x: 0, y: 6)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                        }

                        // Status message - subtly embedded
                        Text(isFirstOfDay ? morningMessages[encouragementIndex] : (isReady ? celebrationMessages[encouragementIndex] : encouragementMessages[encouragementIndex]))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white.opacity(0.9), .white.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(Color.white.opacity(0.06))
                                        .blur(radius: 2)

                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                }
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 30)
                    }
                }
                .padding(.vertical, 40)

                Spacer()

                // Modern Action Buttons
                VStack(spacing: 14) {
                    // Main Action Button
                    Button {
                        if isFirstOfDay {
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                            let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                            defaults.set(true, forKey: "hasStartedTimerToday")
                            statisticsManager.recordDayCompleted()
                            statisticsManager.recordSubstanceTaken()
                            snusManager.takeSnus()
                            encouragementIndex = Int.random(in: 0..<encouragementMessages.count)

                            // Animate snusLeft counter
                            animateSnusLeftCounter()
                        } else if !isReady {
                            showEarlyWarning = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                        } else {
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                            statisticsManager.recordDayCompleted()
                            statisticsManager.recordSubstanceTaken()
                            snusManager.takeSnus()
                            encouragementIndex = Int.random(in: 0..<celebrationMessages.count)
                            isCelebrating = false

                            // Animate snusLeft counter
                            animateSnusLeftCounter()
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill((isReady || isFirstOfDay) ? Color.white.opacity(0.2) : Color.white.opacity(0.15))
                                    .frame(width: 44, height: 44)

                                Image(systemName: (isReady || isFirstOfDay) ? "checkmark.seal.fill" : "timer")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text(isFirstOfDay ? String(format: NSLocalizedString("main.start_day", comment: ""), snusManager.localizedSubstanceNameSingular) : (isReady ? String(format: NSLocalizedString("main.take_one_ready", comment: ""), snusManager.localizedSubstanceNameSingular) : String(format: NSLocalizedString("main.take_one", comment: ""), snusManager.localizedSubstanceNameSingular)))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 26)
                        .padding(.vertical, 20)
                        .background(
                            ZStack {
                                // Gradient background
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: themeManager.currentTheme.buttonGradient(isReady: isReady || isFirstOfDay),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                // Shimmer effect
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.0), .white.opacity(0.2), .white.opacity(0.0)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                // Top highlight for depth
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )

                                // Border glow
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .shadow(
                            color: themeManager.currentTheme.buttonShadowColor(isReady: isReady || isFirstOfDay).opacity(0.5),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                    }
                    .disabled(snusManager.snusLeft == 0)
                    .opacity(snusManager.snusLeft == 0 ? 0.5 : 1.0)
                    .alert(NSLocalizedString("alert.wait_title", comment: ""), isPresented: $showEarlyWarning) {
                        Button(NSLocalizedString("alert.take_anyway", comment: ""), role: .destructive) {
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                            statisticsManager.recordSubstanceTaken()
                            snusManager.takeSnus()
                            encouragementIndex = Int.random(in: 0..<encouragementMessages.count)

                            // Animate snusLeft counter
                            animateSnusLeftCounter()
                        }
                        Button(NSLocalizedString("alert.ok_wait", comment: ""), role: .cancel) {}
                    } message: {
                        Text(String(format: NSLocalizedString("alert.time_remaining", comment: ""), timeString(from: snusManager.countdownTime)))
                    }

                    // Secondary buttons row
                    HStack(spacing: 12) {
                        // Panic Button
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                            snusManager.usePanicSnus()

                            // Animate only panic counter
                            animatePanicLeftCounter()
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "bolt.shield.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text(NSLocalizedString("main.panic", comment: ""))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: snusManager.paniksnusLeft > 0 ? [.red, .orange] : [.gray, .gray.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.20), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )

                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.35), .white.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: snusManager.paniksnusLeft > 0 ? Color.red.opacity(0.4) : Color.clear, radius: 12, x: 0, y: 6)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                        .disabled(snusManager.paniksnusLeft == 0)
                        .opacity(snusManager.paniksnusLeft == 0 ? 0.5 : 1.0)

                        // Statistics Button - Redesigned with subtle cyan gradient
                        Button {
                            showingStatistics = true
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text(NSLocalizedString("main.statistics", comment: ""))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    // Subtle gradient background
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.cyan.opacity(0.15),
                                                    Color.blue.opacity(0.10)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .background(.ultraThinMaterial.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 18))

                                    // Top highlight for depth
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.18), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )

                                    // Border with subtle color
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.4), .blue.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: .cyan.opacity(0.2), radius: 8, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }

                        // Settings Button - Redesigned with subtle purple gradient
                        Button {
                            showingSettings = true
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .indigo],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text(NSLocalizedString("main.settings", comment: ""))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    // Subtle gradient background
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.purple.opacity(0.15),
                                                    Color.indigo.opacity(0.10)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .background(.ultraThinMaterial.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 18))

                                    // Top highlight for depth
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.18), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )

                                    // Border with subtle color
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.purple.opacity(0.4), .indigo.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: isIPad ? 900 : .infinity)
            .frame(maxWidth: .infinity) // Center on iPad
        }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(snusManager: snusManager, onRestartApp: {
                showingSettings = false
                onRestartApp()
            })
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(statisticsManager: statisticsManager)
        }
        .onAppear {
            // Check for daily reset
            snusManager.checkForDailyReset()

            // Load timer display format from UserDefaults
            let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
            timerDisplayFormat = defaults.string(forKey: UserDefaultsKeys.timerDisplayFormat) ?? "HH:MM"

            // Set random message index on appear
            if isFirstOfDay {
                encouragementIndex = Int.random(in: 0..<morningMessages.count)
            }

            // Check if timer just completed
            if snusManager.countdownTime == 0 && !isFirstOfDay && !isCelebrating {
                triggerCelebration()
            }
        }
        .onChange(of: snusManager.countdownTime) { oldValue, newValue in
            // Trigger celebration when timer reaches 0
            if newValue == 0 && !isFirstOfDay && !isCelebrating {
                triggerCelebration()
            }
        }
        .onChange(of: showingSettings) { oldValue, newValue in
            // When settings view is dismissed, reload timer display format
            if oldValue == true && newValue == false {
                let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                timerDisplayFormat = defaults.string(forKey: UserDefaultsKeys.timerDisplayFormat) ?? "HH:MM"
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    func triggerCelebration() {
        // Don't celebrate on first snus of the day
        guard !isFirstOfDay else { return }

        isCelebrating = true
        encouragementIndex = Int.random(in: 0..<celebrationMessages.count)

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Celebration ring animation
        withAnimation(.easeOut(duration: 1.5)) {
            celebrationScale = 2.0
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            celebrationScale = 1.0
        }
    }

    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60

        switch timerDisplayFormat {
        case "HH":
            return String(format: "%02d", hours)
        case "HH:MM:SS":
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        default: // "HH:MM"
            return String(format: "%02d:%02d", hours, minutes)
        }
    }

    func animateSnusLeftCounter() {
        // Scale up with spring animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            snusLeftScale = 1.15
        }

        // Scale back down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                snusLeftScale = 1.0
            }
        }
    }

    func animatePanicLeftCounter() {
        // Scale up with spring animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            panicLeftScale = 1.15
        }

        // Scale back down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                panicLeftScale = 1.0
            }
        }
    }
}

// MARK: - Modern Stat Card
struct ModernStatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: LinearGradient
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Enhanced glow effect
                Circle()
                    .fill(gradient)
                    .frame(width: 68, height: 68)
                    .blur(radius: 15)
                    .opacity(0.7)

                // Outer ring for depth
                Circle()
                    .stroke(gradient.opacity(0.3), lineWidth: 2)
                    .frame(width: 58, height: 58)

                // Icon background with gradient
                Circle()
                    .fill(gradient)
                    .frame(width: 54, height: 54)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .scaleEffect(scale)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .scaleEffect(scale)

                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .textCase(.uppercase)
                    .tracking(1.0)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 26)
        .background(
            ZStack {
                // Base glassmorphic background
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.10))
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                // Gradient border
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

                // Top highlight
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        )
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Mesh Gradient Background
struct MeshGradientBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Enhanced base gradient with richer colors
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.32),
                    Color(red: 0.20, green: 0.12, blue: 0.42),
                    Color(red: 0.16, green: 0.10, blue: 0.38),
                    Color(red: 0.10, green: 0.06, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated mesh-like gradient overlay with more layers
            ZStack {
                // Top left purple glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.35), Color.indigo.opacity(0.15), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 450
                        )
                    )
                    .offset(x: -120, y: -120)
                    .blur(radius: 70)
                    .offset(y: phase * 25)

                // Top right blue glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.30), Color.cyan.opacity(0.12), Color.clear],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .offset(x: 120, y: -80)
                    .blur(radius: 80)
                    .offset(y: -phase * 18)

                // Bottom pink/magenta glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.pink.opacity(0.25), Color.purple.opacity(0.10), Color.clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 350
                        )
                    )
                    .offset(x: 60, y: 120)
                    .blur(radius: 60)
                    .offset(y: phase * 15)

                // Center accent glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.indigo.opacity(0.20), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .blur(radius: 50)
                    .offset(x: phase * -10)
            }

            // Subtle noise overlay for texture
            Rectangle()
                .fill(Color.white.opacity(0.02))
                .blendMode(.overlay)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var snusManager: SnusManager
    var onRestartApp: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var snusInterval: Int
    @State private var paniksnus: Int
    @State private var showCheatAlert = false
    @State private var showResetConfirmation = false
    @State private var initialSnusLeft: Int
    @State private var showIntervalWarning = false
    @State private var showIntervalPraise = false
    @State private var showPaniksnusWarning = false
    @State private var showPaniksnusPraise = false
    @State private var showPaniksnusLeftWarning = false
    @State private var initialSnusInterval: Int
    @State private var initialPaniksnus: Int
    @State private var snusIntervalBeforeDrag: Int = 0
    @State private var paniksnusBeforeDrag: Int = 0
    @State private var paniksnusLeftBeforeDrag: Int = 0
    @State private var snusLeftBeforeDrag: Int = 0
    @State private var showChangeSubstanceConfirmation = false
    @State private var isDynamicIslandEnabled: Bool
    @State private var isTimerNotificationEnabled: Bool
    @State private var timerDisplayFormat: String
    @State private var selectedSoundID: UInt32
    @State private var showSoundPicker = false
    @State private var selectedTheme: AppTheme
    @State private var showThemePicker = false

    private let cheatMessages = [
        NSLocalizedString("cheat.no_discipline", comment: ""),
        NSLocalizedString("cheat.we_see_you", comment: ""),
        NSLocalizedString("cheat.come_on", comment: ""),
        NSLocalizedString("cheat.little_cheater", comment: ""),
        NSLocalizedString("cheat.self_control", comment: ""),
        NSLocalizedString("cheat.you_know", comment: ""),
        NSLocalizedString("cheat.nice_job", comment: ""),
        NSLocalizedString("cheat.first_step", comment: "")
    ]

    private let intervalPraiseMessages = [
        NSLocalizedString("interval_praise.serious", comment: ""),
        NSLocalizedString("interval_praise.discipline", comment: ""),
        NSLocalizedString("interval_praise.fantastic", comment: ""),
        NSLocalizedString("interval_praise.way_forward", comment: ""),
        NSLocalizedString("interval_praise.respect", comment: ""),
        NSLocalizedString("interval_praise.continue", comment: ""),
        NSLocalizedString("interval_praise.attitude", comment: ""),
        NSLocalizedString("interval_praise.strong", comment: "")
    ]

    private let intervalWarningMessages = [
        NSLocalizedString("interval_warning.backwards", comment: ""),
        NSLocalizedString("interval_warning.less_control", comment: ""),
        NSLocalizedString("interval_warning.wrong_way", comment: ""),
        NSLocalizedString("interval_warning.not_right", comment: ""),
        NSLocalizedString("interval_warning.more_snus", comment: ""),
        NSLocalizedString("interval_warning.decrease", comment: ""),
        NSLocalizedString("interval_warning.backwards_person", comment: ""),
        NSLocalizedString("interval_warning.alert", comment: "")
    ]

    private let paniksnusPraiseMessages = [
        NSLocalizedString("panic_praise.finally", comment: ""),
        NSLocalizedString("panic_praise.mature", comment: ""),
        NSLocalizedString("panic_praise.yes", comment: ""),
        NSLocalizedString("panic_praise.look_at_you", comment: ""),
        NSLocalizedString("panic_praise.impressive", comment: ""),
        NSLocalizedString("panic_praise.trust", comment: ""),
        NSLocalizedString("panic_praise.right_decision", comment: ""),
        NSLocalizedString("panic_praise.winner", comment: "")
    ]

    private let paniksnusWarningMessages = [
        NSLocalizedString("panic_warning.feeling_unsafe", comment: ""),
        NSLocalizedString("panic_warning.less_trust", comment: ""),
        NSLocalizedString("panic_warning.really_need", comment: ""),
        NSLocalizedString("panic_warning.lack_confidence", comment: ""),
        NSLocalizedString("panic_warning.wrong_direction", comment: ""),
        NSLocalizedString("panic_warning.afraid", comment: ""),
        NSLocalizedString("panic_warning.backup", comment: ""),
        NSLocalizedString("panic_warning.strength", comment: "")
    ]

    private let paniksnusLeftWarningMessages = [
        NSLocalizedString("panic_left.increasing", comment: ""),
        NSLocalizedString("panic_left.we_see", comment: ""),
        NSLocalizedString("panic_left.creative", comment: ""),
        NSLocalizedString("panic_left.thought", comment: ""),
        NSLocalizedString("panic_left.cheating", comment: ""),
        NSLocalizedString("panic_left.tsk", comment: ""),
        NSLocalizedString("panic_left.remember", comment: ""),
        NSLocalizedString("panic_left.no_no", comment: "")
    ]

    init(snusManager: SnusManager, onRestartApp: @escaping () -> Void) {
        _snusManager = ObservedObject(wrappedValue: snusManager)
        self.onRestartApp = onRestartApp
        _snusInterval = State(initialValue: Int(snusManager.snusInterval / 3600))
        _paniksnus = State(initialValue: snusManager.paniksnus)
        _initialSnusLeft = State(initialValue: snusManager.snusLeft)
        _initialSnusInterval = State(initialValue: Int(snusManager.snusInterval / 3600))
        _initialPaniksnus = State(initialValue: snusManager.paniksnus)

        // Load Dynamic Island setting (default to true if not set)
        let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        if defaults.object(forKey: UserDefaultsKeys.isDynamicIslandEnabled) == nil {
            defaults.set(true, forKey: UserDefaultsKeys.isDynamicIslandEnabled) // Set default
        }
        _isDynamicIslandEnabled = State(initialValue: defaults.bool(forKey: UserDefaultsKeys.isDynamicIslandEnabled))

        // Load Timer Notification setting (default to true if not set)
        if defaults.object(forKey: UserDefaultsKeys.isTimerNotificationEnabled) == nil {
            defaults.set(true, forKey: UserDefaultsKeys.isTimerNotificationEnabled) // Set default
        }
        _isTimerNotificationEnabled = State(initialValue: defaults.bool(forKey: UserDefaultsKeys.isTimerNotificationEnabled))

        // Load Timer Display Format setting (default to "HH:MM" if not set)
        let savedFormat = defaults.string(forKey: UserDefaultsKeys.timerDisplayFormat) ?? "HH:MM"
        _timerDisplayFormat = State(initialValue: savedFormat)

        // Load Timer Completion Sound setting (default to 1315 - Anticipate)
        let savedSoundID = defaults.object(forKey: UserDefaultsKeys.timerCompletionSoundID) as? UInt32 ?? 1315
        _selectedSoundID = State(initialValue: savedSoundID)

        // Load Theme setting (default to purpleDream)
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.purpleDream.rawValue
        _selectedTheme = State(initialValue: AppTheme(rawValue: savedTheme) ?? .purpleDream)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: selectedTheme.primaryColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Text(NSLocalizedString("settings.title", comment: ""))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                    // Settings Cards
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: selectedTheme.accentGradient,
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        Text(String(format: NSLocalizedString("settings.interval", comment: ""), snusManager.localizedSubstanceName))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(snusInterval) " + NSLocalizedString("setup.hours", comment: ""))
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(snusInterval) },
                                        set: { newValue in
                                            snusInterval = Int(newValue)
                                        }
                                    ), in: 1...8, step: 1, onEditingChanged: { isEditing in
                                        if isEditing {
                                            // User started dragging - save the current value
                                            snusIntervalBeforeDrag = snusInterval
                                        } else {
                                            // User released - compare, show alert, and auto-save
                                            if snusInterval > snusIntervalBeforeDrag {
                                                showIntervalPraise = true
                                            } else if snusInterval < snusIntervalBeforeDrag {
                                                showIntervalWarning = true
                                            }
                                            // Auto-save settings
                                            applySettings()
                                        }
                                    })
                                    .tint(selectedTheme.accentGradient[0])
                                }

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.red)
                                        Text(String(format: NSLocalizedString("settings.panic_per_week", comment: ""), snusManager.localizedSubstanceName))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(paniksnus)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(paniksnus) },
                                        set: { newValue in
                                            paniksnus = Int(newValue)
                                        }
                                    ), in: 1...10, step: 1, onEditingChanged: { isEditing in
                                        if isEditing {
                                            // User started dragging - save the current value
                                            paniksnusBeforeDrag = paniksnus
                                        } else {
                                            // User released - compare, show alert, and auto-save
                                            if paniksnus < paniksnusBeforeDrag {
                                                showPaniksnusPraise = true
                                            } else if paniksnus > paniksnusBeforeDrag {
                                                showPaniksnusWarning = true
                                            }
                                            // Auto-save settings
                                            applySettings()
                                        }
                                    })
                                    .tint(.red)
                                }
                            }
                        }

                        GlassCard {
                            VStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(String(format: NSLocalizedString("settings.amount_left_today", comment: ""), snusManager.localizedSubstanceName))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(snusManager.snusLeft)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(snusManager.snusLeft) },
                                        set: { newValue in
                                            snusManager.snusLeft = Int(newValue)
                                        }
                                    ), in: 0...20, step: 1, onEditingChanged: { isEditing in
                                        if isEditing {
                                            // User started dragging - save the current value
                                            snusLeftBeforeDrag = snusManager.snusLeft
                                        } else {
                                            // User released - compare, show alert, and auto-save
                                            if snusManager.snusLeft > snusLeftBeforeDrag {
                                                showCheatAlert = true
                                            }
                                            // Auto-save (snusLeft is already updated in snusManager)
                                            snusManager.saveSettings()
                                        }
                                    })
                                    .tint(.green)
                                }

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                        Text(String(format: NSLocalizedString("settings.panic_left", comment: ""), snusManager.localizedSubstanceName))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(snusManager.paniksnusLeft)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(snusManager.paniksnusLeft) },
                                        set: { newValue in
                                            snusManager.paniksnusLeft = Int(newValue)
                                        }
                                    ), in: 0...10, step: 1, onEditingChanged: { isEditing in
                                        if isEditing {
                                            // User started dragging - save the current value
                                            paniksnusLeftBeforeDrag = snusManager.paniksnusLeft
                                        } else {
                                            // User released - compare, show alert, and auto-save
                                            if snusManager.paniksnusLeft > paniksnusLeftBeforeDrag {
                                                showPaniksnusLeftWarning = true
                                            }
                                            // Auto-save (paniksnusLeft is already updated in snusManager)
                                            snusManager.saveSettings()
                                        }
                                    })
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Reset Button
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                        showResetConfirmation = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(NSLocalizedString("settings.reset_day", comment: ""))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.20), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.35), .white.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .alert(NSLocalizedString("alert.reset_day_title", comment: ""), isPresented: $showResetConfirmation) {
                        Button(NSLocalizedString("alert.cancel", comment: ""), role: .cancel) {}
                        Button(NSLocalizedString("alert.reset", comment: ""), role: .destructive) {
                            resetDay()
                        }
                    } message: {
                        Text(String(format: NSLocalizedString("alert.reset_day_message", comment: ""), snusManager.localizedSubstanceNameSingular))
                    }

                    // Change Substance Button
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                        showChangeSubstanceConfirmation = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(NSLocalizedString("settings.change_substance", comment: ""))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .indigo],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.20), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.35), .white.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .alert(NSLocalizedString("alert.change_substance_title", comment: ""), isPresented: $showChangeSubstanceConfirmation) {
                        Button(NSLocalizedString("alert.cancel", comment: ""), role: .cancel) {}
                        Button(NSLocalizedString("alert.change", comment: ""), role: .destructive) {
                            changeSubstance()
                        }
                    } message: {
                        Text(NSLocalizedString("alert.change_substance_message", comment: ""))
                    }

                    // Dynamic Island Toggle
                    GlassCard {
                        HStack(spacing: 14) {
                            Image(systemName: "moon.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: isDynamicIslandEnabled ? [.purple, .indigo] : [.gray, .gray.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(NSLocalizedString("settings.dynamic_island_toggle_title", comment: ""))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text(NSLocalizedString("settings.dynamic_island_toggle_message", comment: ""))
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)

                            Toggle("", isOn: Binding(
                                get: { isDynamicIslandEnabled },
                                set: { newValue in
                                    isDynamicIslandEnabled = newValue
                                    let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                    defaults.set(newValue, forKey: UserDefaultsKeys.isDynamicIslandEnabled)

                                    if !newValue {
                                        // Turning off - end Live Activity immediately
                                        Task {
                                            await snusManager.endLiveActivityPublic()
                                        }
                                    } else {
                                        // Turning on - start Live Activity if timer is active
                                        let isTimerActive = defaults.bool(forKey: "isTimerActive")
                                        if isTimerActive && snusManager.countdownTime > 0 {
                                            // Restart timer with new interval to trigger Live Activity
                                            snusManager.restartTimerWithNewInterval()
                                        }
                                    }
                                }
                            ))
                            .tint(.purple)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Timer Notification Toggle
                    GlassCard {
                        HStack(spacing: 14) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: isTimerNotificationEnabled ? [.green, .mint] : [.gray, .gray.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(NSLocalizedString("settings.timer_notification_title", comment: ""))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text(NSLocalizedString("settings.timer_notification_subtitle", comment: ""))
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)

                            Toggle("", isOn: Binding(
                                get: { isTimerNotificationEnabled },
                                set: { newValue in
                                    isTimerNotificationEnabled = newValue
                                    let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                    defaults.set(newValue, forKey: UserDefaultsKeys.isTimerNotificationEnabled)
                                }
                            ))
                            .tint(.green)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Timer Completion Sound Picker (only show when notifications are enabled)
                    if isTimerNotificationEnabled {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showSoundPicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.orange, .pink],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(NSLocalizedString("settings.timer_sound_title", comment: ""))
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)

                                            if let selectedSound = availableTimerSounds.first(where: { $0.id == selectedSoundID }) {
                                                Text(selectedSound.localizedName)
                                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.75))
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: showSoundPicker ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showSoundPicker {
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                        .padding(.vertical, 4)

                                    VStack(spacing: 8) {
                                        ForEach(availableTimerSounds) { sound in
                                            Button {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()

                                                // Play preview of the sound
                                                AudioServicesPlaySystemSound(SystemSoundID(sound.id))

                                                // Save selection
                                                selectedSoundID = sound.id
                                                let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                                defaults.set(sound.id, forKey: UserDefaultsKeys.timerCompletionSoundID)
                                            } label: {
                                                HStack {
                                                    Text(sound.localizedName)
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundColor(.white.opacity(0.9))

                                                    Spacer()

                                                    if selectedSoundID == sound.id {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 18))
                                                            .foregroundColor(.green)
                                                    } else {
                                                        Image(systemName: "circle")
                                                            .font(.system(size: 18))
                                                            .foregroundColor(.white.opacity(0.3))
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(selectedSoundID == sound.id ? Color.white.opacity(0.15) : Color.clear)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }

                    // Theme Picker
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showThemePicker.toggle()
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: selectedTheme.accentGradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(NSLocalizedString("settings.theme_title", comment: ""))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)

                                        Text(selectedTheme.localizedName)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.75))
                                    }

                                    Spacer()

                                    Image(systemName: showThemePicker ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            if showThemePicker {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                    .padding(.vertical, 4)

                                VStack(spacing: 8) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()

                                            // Save selection
                                            selectedTheme = theme
                                            UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
                                            ThemeManager.shared.currentTheme = theme
                                        } label: {
                                            HStack {
                                                // Theme color preview
                                                HStack(spacing: 4) {
                                                    ForEach(0..<theme.primaryColors.count, id: \.self) { index in
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(theme.primaryColors[index])
                                                            .frame(width: 24, height: 24)
                                                    }
                                                }

                                                Text(theme.localizedName)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.9))

                                                Spacer()

                                                if selectedTheme == theme {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 18))
                                                        .foregroundColor(.green)
                                                } else {
                                                    Image(systemName: "circle")
                                                        .font(.system(size: 18))
                                                        .foregroundColor(.white.opacity(0.3))
                                                }
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedTheme == theme ? Color.white.opacity(0.15) : Color.clear)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Timer Display Format
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(NSLocalizedString("settings.timer_format_title", comment: ""))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)

                                    Text(NSLocalizedString("settings.timer_format_subtitle", comment: ""))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                            }

                            VStack(spacing: 10) {
                                // HH option
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    timerDisplayFormat = "HH"
                                    let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                    defaults.set("HH", forKey: UserDefaultsKeys.timerDisplayFormat)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(NSLocalizedString("settings.timer_format_hours", comment: ""))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(NSLocalizedString("settings.timer_format_hours_example", comment: ""))
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        if timerDisplayFormat == "HH" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(timerDisplayFormat == "HH" ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(timerDisplayFormat == "HH" ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
                                }

                                // HH:MM option
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    timerDisplayFormat = "HH:MM"
                                    let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                    defaults.set("HH:MM", forKey: UserDefaultsKeys.timerDisplayFormat)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(NSLocalizedString("settings.timer_format_hours_minutes", comment: ""))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(NSLocalizedString("settings.timer_format_hours_minutes_example", comment: ""))
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        if timerDisplayFormat == "HH:MM" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(timerDisplayFormat == "HH:MM" ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(timerDisplayFormat == "HH:MM" ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
                                }

                                // HH:MM:SS option
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    timerDisplayFormat = "HH:MM:SS"
                                    let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
                                    defaults.set("HH:MM:SS", forKey: UserDefaultsKeys.timerDisplayFormat)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(NSLocalizedString("settings.timer_format_hours_minutes_seconds", comment: ""))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(NSLocalizedString("settings.timer_format_hours_minutes_seconds_example", comment: ""))
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        if timerDisplayFormat == "HH:MM:SS" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(timerDisplayFormat == "HH:MM:SS" ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(timerDisplayFormat == "HH:MM:SS" ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: isIPad ? 900 : .infinity)
            .frame(maxWidth: .infinity) // Center on iPad
        }
        .foregroundColor(.white)
        .alert(NSLocalizedString("alert.cheating_title", comment: ""), isPresented: $showCheatAlert) {
            Button(NSLocalizedString("alert.cheating_yes", comment: ""), role: .destructive) {
                // User acknowledges they're cheating
            }
            Button(NSLocalizedString("alert.cheating_no", comment: ""), role: .cancel) {
                // Revert the change
                snusManager.snusLeft = initialSnusLeft
            }
        } message: {
            Text(cheatMessages.randomElement() ?? cheatMessages[0])
        }
        .alert(NSLocalizedString("alert.fantastic_title", comment: ""), isPresented: $showIntervalPraise) {
            Button(NSLocalizedString("alert.thanks", comment: ""), role: .cancel) {}
        } message: {
            Text(intervalPraiseMessages.randomElement() ?? intervalPraiseMessages[0])
        }
        .alert(NSLocalizedString("alert.wrong_way_title", comment: ""), isPresented: $showIntervalWarning) {
            Button(NSLocalizedString("alert.understand", comment: ""), role: .cancel) {}
        } message: {
            Text(intervalWarningMessages.randomElement() ?? intervalWarningMessages[0])
        }
        .alert(NSLocalizedString("alert.good_job_title", comment: ""), isPresented: $showPaniksnusPraise) {
            Button(NSLocalizedString("alert.thanks", comment: ""), role: .cancel) {}
        } message: {
            Text(paniksnusPraiseMessages.randomElement() ?? paniksnusPraiseMessages[0])
        }
        .alert(NSLocalizedString("alert.hmm_title", comment: ""), isPresented: $showPaniksnusWarning) {
            Button(NSLocalizedString("alert.ok_ok", comment: ""), role: .cancel) {}
        } message: {
            Text(paniksnusWarningMessages.randomElement() ?? paniksnusWarningMessages[0])
        }
        .alert(NSLocalizedString("alert.cheater_title", comment: ""), isPresented: $showPaniksnusLeftWarning) {
            Button(NSLocalizedString("alert.cheating_yes", comment: ""), role: .destructive) {}
            Button(NSLocalizedString("alert.cheating_no", comment: ""), role: .cancel) {
                // Revert the change (this will need the initial value)
            }
        } message: {
            Text(paniksnusLeftWarningMessages.randomElement() ?? paniksnusLeftWarningMessages[0])
        }
        .onAppear {
            // Store initial values when settings view appears
            initialSnusLeft = snusManager.snusLeft
        }
    }

    func applySettings() {
        // Check if timer is active and interval changed
        let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        let isTimerActive = defaults.bool(forKey: "isTimerActive")
        let oldInterval = snusManager.snusInterval
        let newInterval = TimeInterval(snusInterval * 3600)
        let intervalChanged = oldInterval != newInterval && oldInterval > 0

        // If timer is active and interval changed, adjust countdown proportionally
        if isTimerActive && intervalChanged {
            // Calculate progress percentage (how much of the timer has elapsed)
            let progressPercentage = 1.0 - (snusManager.countdownTime / oldInterval)

            // Apply progress to new interval
            let newCountdownTime = newInterval * (1.0 - progressPercentage)
            snusManager.countdownTime = max(0, newCountdownTime)

            // Update timer end date for accuracy
            let newEndDate = Date().addingTimeInterval(snusManager.countdownTime)
            let newStartTime = newEndDate.addingTimeInterval(-newInterval)

            // Save updated timer state
            defaults.set(newStartTime, forKey: "timerStartTime")
            defaults.set(snusManager.countdownTime, forKey: "countdownTime")
        }

        // Update interval in manager BEFORE restarting timer
        snusManager.snusInterval = newInterval
        snusManager.paniksnus = paniksnus
        snusManager.saveSettings()

        // If timer was active and interval changed, restart timer to apply changes immediately
        if isTimerActive && intervalChanged {
            snusManager.restartTimerWithNewInterval()
        }
    }

    func resetDay() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // Stop timer and Live Activity completely
        snusManager.stopAndResetTimer()

        // Reset to daily starting values
        snusManager.snusLeft = 10
        // Note: paniksnusLeft is NOT reset here as it's weekly, not daily

        // Reset the "first of day" flag so user sees "Starta dagen med en snus!"
        let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        defaults.set(false, forKey: "hasStartedTimerToday")

        snusManager.saveSettings()

        // Close settings view to return to landing page
        presentationMode.wrappedValue.dismiss()
    }

    func changeSubstance() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // Stop timer and Live Activity completely
        snusManager.stopAndResetTimer()

        // Reset EVERYTHING - including hasBeenInitialized!
        let defaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        defaults.set(false, forKey: "hasConfiguredSettings")
        defaults.set(false, forKey: "hasStartedTimerToday")
        defaults.set(false, forKey: "hasBeenInitialized")  // CRITICAL - reset this too!

        // Clear all settings including selected substance
        defaults.removeObject(forKey: "snusInterval")
        defaults.removeObject(forKey: "paniksnus")
        defaults.removeObject(forKey: "snusLeft")
        defaults.removeObject(forKey: "paniksnusLeft")
        defaults.removeObject(forKey: "timerEndDate")
        defaults.removeObject(forKey: "selectedSubstance")
        defaults.removeObject(forKey: "countdownTime")
        defaults.removeObject(forKey: "isTimerActive")
        defaults.removeObject(forKey: "timerStartTime")
        // NO synchronize() needed - UserDefaults automatically saves changes

        // Restart app flow - triggers automatic restart
        onRestartApp()
    }
}

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    @StateObject private var themeManager = ThemeManager.shared

    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: themeManager.currentTheme.accentGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            content
        }
        .foregroundColor(.white)
    }
}


