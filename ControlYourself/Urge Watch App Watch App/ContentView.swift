//
//  ContentView.swift
//  Urge Watch App
//
//  Main Watch interface for Urge
//

import SwiftUI
import Combine
import WatchKit
import UserNotifications

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var currentTime = Date()
    @State private var wasTimerRunning = false
    @State private var showEarlyWarning = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Connection status
                if !connectivity.isConnected {
                    HStack {
                        Image(systemName: "iphone.slash")
                            .foregroundColor(.red)
                        Text("Not Connected")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }

                // Timer Display
                VStack(spacing: 8) {
                    if connectivity.countdownTime <= 0 {
                        // Ready to take
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("Ready!")
                            .font(.title2.bold())
                            .foregroundColor(.green)
                    } else {
                        // Countdown active
                        Text(timeString(from: connectivity.countdownTime))
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("until next")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                // Stats
                HStack(spacing: 12) {
                    StatBadge(
                        icon: "circle.hexagongrid.fill",
                        value: "\(connectivity.snusLeft)",
                        label: "Left",
                        color: .green
                    )

                    StatBadge(
                        icon: "bolt.shield.fill",
                        value: "\(connectivity.paniksnusLeft)",
                        label: "Panic",
                        color: connectivity.paniksnusLeft > 0 ? .red : .gray
                    )
                }

                // Action Buttons
                VStack(spacing: 10) {
                    // Main action button
                    Button {
                        if connectivity.countdownTime <= 0 {
                            // Haptic feedback for success
                            WKInterfaceDevice.current().play(.success)
                            connectivity.takeSnus()
                        } else {
                            // Show warning if trying to take too early (same as iPhone)
                            showEarlyWarning = true
                        }
                    } label: {
                        Label(
                            "Take One",
                            systemImage: "hand.tap.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(connectivity.countdownTime <= 0 ? .green : .purple)

                    // Panic button
                    if connectivity.paniksnusLeft > 0 {
                        Button {
                            // Haptic feedback for warning/panic action
                            WKInterfaceDevice.current().play(.notification)
                            connectivity.usePanic()
                        } label: {
                            Label("Use Panic", systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity)
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            currentTime = Date()

            // Update countdown based on timer end date
            if let endDate = connectivity.timerEndDate {
                let remaining = endDate.timeIntervalSinceNow
                if remaining > 0 {
                    connectivity.countdownTime = remaining
                    wasTimerRunning = true
                } else {
                    connectivity.countdownTime = 0
                    connectivity.timerEndDate = nil

                    // Play haptic feedback when timer completes (only once)
                    if wasTimerRunning {
                        WKInterfaceDevice.current().play(.success)
                        wasTimerRunning = false
                    }
                }
            }
        }
        .onAppear {
            // Request initial update
            connectivity.requestUpdate()
        }
        .alert("Wait a bit longer!", isPresented: $showEarlyWarning) {
            Button("Take anyway", role: .destructive) {
                WKInterfaceDevice.current().play(.notification)
                connectivity.takeSnus()
            }
            Button("Okay, I'll wait", role: .cancel) {}
        } message: {
            Text("You have \(timeString(from: connectivity.countdownTime)) left. Are you sure you want to take one now?")
        }
    }

    private func timeString(from seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title3.bold())
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
