//
//  ContentView.swift
//  ControlYourself
//
//  Created by Jens on 2024-03-29.
//

import SwiftUI
import UserNotifications

// MARK: - Design System
struct AppTheme {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.11, green: 0.13, blue: 0.18),
            Color(red: 0.17, green: 0.20, blue: 0.27)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.42, green: 0.36, blue: 0.90),
            Color(red: 0.55, green: 0.27, blue: 0.87)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.82, blue: 0.60),
            Color(red: 0.0, green: 0.70, blue: 0.52)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let warningGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.75, blue: 0.0),
            Color(red: 1.0, green: 0.60, blue: 0.0)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let dangerGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.23, blue: 0.19),
            Color(red: 0.93, green: 0.11, blue: 0.14)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cigaretteGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.95, green: 0.40, blue: 0.67),  // Pink
            Color(red: 0.85, green: 0.30, blue: 0.85)   // Magenta/Purple
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let accent = Color(red: 0.42, green: 0.36, blue: 0.90)
}

struct ModernButtonStyle: ButtonStyle {
    var gradient: LinearGradient
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(gradient)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(configuration.isPressed ? 0.2 : 0))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: configuration.isPressed ? 5 : 15, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GlassmorphicButtonStyle: ButtonStyle {
    var accentColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(accentColor.opacity(0.15))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension LinearGradient {
    var startColor: Color {
        return Color(red: 0.42, green: 0.36, blue: 0.90)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.08))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - App Content
enum Njutning: String {
    case snus = "snus"
    case cigaretter = "cigarettes"

    var localizedName: String {
        switch self {
        case .snus:
            return NSLocalizedString("substance.snus", comment: "")
        case .cigaretter:
            return NSLocalizedString("substance.cigarettes", comment: "")
        }
    }
}

struct ContentView: View {
    @StateObject var snusManager = SnusManager()
    @StateObject var subscriptionManager = SubscriptionManager.shared
    @StateObject var statisticsManager = StatisticsManager()
    @State private var showWelcome = true
    @State private var selectedNjutning: Njutning? = nil
    @State private var navigateToLandingPage = false
    @State private var restartApp = false
    @State private var showPaywall = false

    var hasConfiguredSettings: Bool {
        // Check if app has been installed before using standard UserDefaults
        // (App Group UserDefaults can survive app deletion, but standard UserDefaults won't)
        let standardDefaults = UserDefaults.standard
        let isAppInstalled = standardDefaults.bool(forKey: "appHasBeenInstalled")

        // If app hasn't been marked as installed, this is a fresh install
        if !isAppInstalled {
            // Mark app as installed in standard UserDefaults
            standardDefaults.set(true, forKey: "appHasBeenInstalled")
            // Set install date for trial tracking
            standardDefaults.set(Date(), forKey: "firstLaunchDate")

            // Clear any leftover App Group settings from previous installations
            let sharedDefaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
            sharedDefaults.removeObject(forKey: "hasConfiguredSettings")
            sharedDefaults.removeObject(forKey: "hasBeenInitialized")

            return false // First time, not configured
        }

        // Check App Group UserDefaults for configuration status
        let sharedDefaults = UserDefaults(suiteName: "group.com.JensEH.ControlYourself") ?? UserDefaults.standard
        return sharedDefaults.bool(forKey: "hasConfiguredSettings")
    }

    var shouldShowPaywall: Bool {
        // Never show if already subscribed
        guard !subscriptionManager.isSubscribed else { return false }

        // Check if user has seen paywall before
        let hasSeenPaywall = UserDefaults.standard.bool(forKey: "hasSeenPaywall")

        // FIRST TIME: Always show paywall once (can be dismissed)
        if !hasSeenPaywall {
            return true
        }

        // AFTER FIRST TIME: Show again after 2 days to remind
        guard let firstLaunch = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date else {
            return false
        }

        let daysSinceInstall = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0

        // Show again after 2 days (more persistent reminder)
        return daysSinceInstall >= 2
    }

    var body: some View {
        NavigationStack {
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showWelcome = false
                            // If already configured, go directly to landing page
                            if hasConfiguredSettings {
                                navigateToLandingPage = true
                            }
                            // Note: Paywall logic moved to LandingPageView.onAppear
                        }
                    }
            } else if navigateToLandingPage {
                LandingPageView(
                    snusManager: snusManager,
                    statisticsManager: statisticsManager,
                    onRestartApp: {
                        // Restart the app flow - reset all state
                        restartApp = true
                        showWelcome = true
                        selectedNjutning = nil
                        navigateToLandingPage = false
                    }
                )
                .onAppear {
                    // Check if we should show paywall after landing page appears
                    if shouldShowPaywall {
                        // Delay 1 second so user sees main screen first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showPaywall = true
                        }
                    }
                }
            } else if let selectedNjutning = selectedNjutning {
                NjutningsInställningarView(
                    snusManager: snusManager,
                    selectedNjutning: selectedNjutning,
                    onSettingsSaved: {
                        navigateToLandingPage = true
                    }
                )
            } else {
                NjutningsValView(selection: $selectedNjutning)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onAppear {
                    // Mark that user has seen the paywall
                    UserDefaults.standard.set(true, forKey: "hasSeenPaywall")
                }
        }
        .onChange(of: restartApp) { _, newValue in
            if newValue {
                // Reset welcome delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showWelcome = false
                    restartApp = false
                }
            }
        }
    }
}


struct NjutningsValView: View {
    @Binding var selection: Njutning?
    @State private var buttonsVisible = false
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Modern mesh gradient background - samma som WelcomeView
            ZStack {
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

                // Animated mesh-like gradient overlay
                ZStack {
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
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text(NSLocalizedString("welcome.title", comment: "Welcome title"))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.27, blue: 0.87),
                                    Color(red: 0.42, green: 0.36, blue: 0.90),
                                    Color(red: 0.60, green: 0.40, blue: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(NSLocalizedString("welcome.subtitle", comment: "Welcome subtitle"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 20)

                VStack(spacing: 20) {
                    ChoiceCard(
                        title: NSLocalizedString("substance.snus", comment: "Snus"),
                        icon: "leaf.fill",
                        gradient: AppTheme.accentGradient
                    ) {
                        selection = .snus
                    }
                    .opacity(buttonsVisible ? 1 : 0)
                    .offset(y: buttonsVisible ? 0 : 20)

                    ChoiceCard(
                        title: NSLocalizedString("substance.cigarettes", comment: "Cigarettes"),
                        icon: "smoke.fill",
                        gradient: AppTheme.cigaretteGradient
                    ) {
                        selection = .cigaretter
                    }
                    .opacity(buttonsVisible ? 1 : 0)
                    .offset(y: buttonsVisible ? 0 : 20)
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase = 1
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                buttonsVisible = true
            }
        }
    }
}

struct ChoiceCard: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: gradient.startColor.opacity(0.4), radius: 12, x: 0, y: 4)

                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(gradient.opacity(0.25))

                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial.opacity(0.6))

                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: gradient.startColor.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


struct NjutningsInställningarView: View {
    @ObservedObject var snusManager: SnusManager
    var selectedNjutning: Njutning
    var onSettingsSaved: () -> Void

    // Local state - starts with default values, NOT what's in snusManager
    @State private var antalPerDag: Int = 10  // Default: 10 per day
    @State private var snusInterval: Int = 2  // Default: 2 hours
    @State private var paniksnus: Int = 5     // Default: 5 panic per week

    // Localized substance name for display
    private var localizedSubstanceName: String {
        if selectedNjutning == .cigaretter {
            return NSLocalizedString("substance.cigarettes", comment: "")
        } else {
            return NSLocalizedString("substance.snus", comment: "")
        }
    }

    var body: some View {
        ZStack {
            AppTheme.primaryGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("setup.title", comment: "Setup title"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))

                        Text(localizedSubstanceName)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accentGradient)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Settings Cards
                    VStack(spacing: 16) {
                        SettingCard {
                            VStack(spacing: 16) {
                                // Antal per dag - VIKTIGAST, kommer först!
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "number.circle.fill")
                                            .foregroundColor(.green)
                                        Text(String(format: NSLocalizedString("setup.amount_per_day", comment: "Amount per day"), localizedSubstanceName.lowercased()))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(antalPerDag)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(antalPerDag) },
                                        set: { antalPerDag = Int($0) }
                                    ), in: 1...20, step: 1)
                                        .tint(.green)
                                }

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                // Intervall mellan
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundStyle(AppTheme.accentGradient)
                                        Text(String(format: NSLocalizedString("setup.interval_between", comment: "Interval between"), localizedSubstanceName.lowercased()))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(snusInterval) " + NSLocalizedString("setup.hours", comment: "hours"))
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Slider(value: Binding(
                                        get: { Double(snusInterval) },
                                        set: { snusInterval = Int($0) }
                                    ), in: 1...8, step: 1)
                                        .tint(AppTheme.accent)
                                }

                                Divider()
                                    .background(Color.white.opacity(0.2))

                                // Paniksnus per vecka
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.red)
                                        Text(String(format: NSLocalizedString("setup.panic_per_week", comment: "Panic per week"), localizedSubstanceName.lowercased()))
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
                                        set: { paniksnus = Int($0) }
                                    ), in: 1...10, step: 1)
                                        .tint(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Save Button
                    Button {
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()

                        // Update SnusManager with local state values
                        snusManager.substanceName = selectedNjutning.rawValue.lowercased()
                        snusManager.snusLeft = antalPerDag              // Set antal per dag
                        snusManager.snusInterval = TimeInterval(snusInterval * 3600)  // Convert hours to seconds
                        snusManager.paniksnus = paniksnus

                        snusManager.saveSettings()
                        onSettingsSaved()
                    } label: {
                        Text(NSLocalizedString("setup.save_continue", comment: "Save and continue"))
                    }
                    .buttonStyle(ModernButtonStyle(gradient: AppTheme.successGradient))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
        }
        .foregroundColor(.white)
    }
}

struct SettingCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Din Color extension för att skapa en färg med en hexadecimal kod.
extension Color {
    init(hexString: String) {
        let scanner = Scanner(string: hexString)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}


struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Modern mesh gradient background - samma som LandingPageView
            ZStack {
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

                // Animated mesh-like gradient overlay
                ZStack {
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
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Animated custom logo - comes first
                CustomLogoView()
                    .frame(width: 220, height: 220)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // App name - simple and universal
                Text("Urge")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.75, green: 0.55, blue: 0.95),  // Light purple
                                Color(red: 0.60, green: 0.45, blue: 0.92),  // Medium purple
                                Color(red: 0.55, green: 0.35, blue: 0.88)   // Rich purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase = 1
            }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
    }
}

// Custom logo view matching app icon design - modern warm purple glassmorphic style
struct CustomLogoView: View {
    var body: some View {
        ZStack {
            // Enhanced backlight glow - warm purple layers for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.65, green: 0.40, blue: 0.95).opacity(0.6),  // Purple glow
                            Color(red: 0.55, green: 0.30, blue: 0.90).opacity(0.4),  // Deeper purple
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .blur(radius: 50)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.65, green: 0.40, blue: 0.95).opacity(0.5),  // Purple glow
                            Color(red: 0.55, green: 0.30, blue: 0.90).opacity(0.3),  // Deeper purple
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .blur(radius: 40)

            // Main circle - warm purple gradient glassmorphic style
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.75, green: 0.50, blue: 0.95).opacity(0.85),  // Light purple
                            Color(red: 0.65, green: 0.40, blue: 0.92).opacity(0.75),  // Medium purple
                            Color(red: 0.55, green: 0.30, blue: 0.88).opacity(0.85)   // Rich purple
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Glassmorphic top highlight
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.purple.opacity(0.6), radius: 40, x: 0, y: 15)
                .shadow(color: Color(red: 0.60, green: 0.35, blue: 0.90).opacity(0.5), radius: 30, x: 0, y: 10)

            // Six white circles in app icon pattern - softer and more subtle
            ZStack {
                // Center circle
                Circle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                // Surrounding 5 circles
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 22, height: 22)
                        .offset(y: -48)
                        .rotationEffect(.degrees(Double(index) * 72)) // 360/5 = 72 degrees
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
