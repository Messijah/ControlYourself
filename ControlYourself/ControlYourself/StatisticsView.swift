//
//  StatisticsView.swift
//  ControlYourself
//
//  Created by Claude on 2025-10-16.
//

import SwiftUI

// MARK: - iPad Layout Helper
fileprivate var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

struct StatisticsView: View {
    @ObservedObject var statisticsManager: StatisticsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            // Modern mesh gradient background
            MeshGradientBackground()
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

                    // Title
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppTheme.successGradient)

                        Text(NSLocalizedString("statistics.title", comment: ""))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 24)

                    // Stats Cards
                    VStack(spacing: 16) {
                        StatCard(
                            icon: "calendar.badge.checkmark",
                            title: NSLocalizedString("statistics.days_in_balance", comment: ""),
                            value: "\(statisticsManager.daysInBalance)",
                            subtitle: NSLocalizedString("statistics.days_since_start", comment: ""),
                            gradient: LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        StatCard(
                            icon: "chart.bar.fill",
                            title: NSLocalizedString("statistics.average_per_day", comment: ""),
                            value: String(format: "%.1f", statisticsManager.averagePerDay),
                            subtitle: NSLocalizedString("statistics.average", comment: ""),
                            gradient: LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        StatCard(
                            icon: "flame.fill",
                            title: NSLocalizedString("statistics.current_streak", comment: ""),
                            value: "\(statisticsManager.currentStreak)",
                            subtitle: NSLocalizedString("statistics.days_in_row", comment: ""),
                            gradient: LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        StatCard(
                            icon: "number.circle.fill",
                            title: NSLocalizedString("statistics.total_used", comment: ""),
                            value: "\(statisticsManager.totalSubstancesUsed)",
                            subtitle: NSLocalizedString("statistics.since_start", comment: ""),
                            gradient: LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .padding(.horizontal, 20)

                    // Info card
                    GlassCard {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("statistics.keep_balance_title", comment: ""))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text(NSLocalizedString("statistics.keep_balance_desc", comment: ""))
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Reset Button
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showResetConfirmation = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 20, weight: .semibold))

                            Text(NSLocalizedString("statistics.reset_button", comment: ""))
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.red.opacity(0.8), .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: isIPad ? 900 : .infinity)
            .frame(maxWidth: .infinity) // Center on iPad
        }
        .foregroundColor(.white)
        .alert(NSLocalizedString("statistics.reset_alert_title", comment: ""), isPresented: $showResetConfirmation) {
            Button(NSLocalizedString("alert.cancel", comment: ""), role: .cancel) { }
            Button(NSLocalizedString("alert.reset", comment: ""), role: .destructive) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                statisticsManager.resetAllStatistics()
            }
        } message: {
            Text(NSLocalizedString("statistics.reset_alert_message", comment: ""))
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)

                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(value)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.10))
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

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
    }
}

#Preview {
    StatisticsView(statisticsManager: StatisticsManager())
}
